// Copyright © 2024 Ambience Healthcare

import Combine
import CoreData

/// # FetchableResultsPublisher
///
/// Publisher which fetches `Fetchable` items from a Core Data managed object context and publishes results using
/// `Combine`, allowing for reactive updates in your UI.
///
/// By encapsulating the complexities of `NSFetchedResultsController` and `Combine`, this publisher simplifies the
/// development process and improves code maintainability.
///
/// ### Usage
///
/// 1. **Initialization:**
///   Create an instance of `FetchableResultsPublisher` with the desired filter, sort criteria, and managed object
/// context. Call `beginFetch()` to start publishing fetch results.
///
///   ```swift
///   let publisher = FetchableResultsPublisher<MyEntity>(
///       filter: .nameContains("Alice"),
///       sort: .nameAscending,
///       moc: myManagedObjectContext
///   )
///   publisher.beginFetch()
///   ```
///
/// 2. **Subscribing to Updates:**
///   Subscribe to the `fetchedObjectsPublisher` or `diffPublisher` to receive updates whenever the underlying data
/// changes.
///
///   ```swift
///   let cancellable = publisher.fetchedObjectsPublisher
///       .sink { fetchedObjects in
///           // Update your UI with the fetched objects
///       }
///   ```
///
/// 3. **Dynamic Updates:**
///   You can dynamically update the filter, sort, fetch limit, or fetch offset, and the publisher will automatically
/// fetch the updated data.
///
///   ```swift
///   publisher.filter = .ageGreaterThan(25)
///   publisher.sort = .nameAscending
///   ```
///
/// 4. **Lifecycle Management:**
///   Control fetching lifecycle using `beginFetch()` and `endFetch()` as needed.
///
/// ### Thread Safety
/// The FetchableResultsPublisher is designed to be used on the main thread, as indicated by the @MainActor attribute.
///
/// ### Advanced Usage
///
/// The `diffPublisher` allows you to observe only the differences (changes) in the fetched entities, which can be more
/// efficient for certain scenarios, such as when throttling or combining publishers.
///
/// ```swift
/// let diffCancellable = publisher.diffPublisher
///    .sink { diff in
///        // Handle changes in the fetched objects
///    }
@MainActor
public class FetchableResultsPublisher<ResultType>: NSObject, NSFetchedResultsControllerDelegate,
    FetchableResultsPublishing where ResultType: NSManagedObject, ResultType: Fetchable
{

    // MARK: Lifecycle

    public init(
        filter: ResultType.Filter? = nil,
        sort: ResultType.Sort? = nil,
        moc: NSManagedObjectContext,
        fetchLimit: Int = 0,
        fetchOffset: Int = 0
    ) {
        self.filter = filter
        self.sort = sort
        self.moc = moc
        self.fetchLimit = fetchLimit
        self.fetchOffset = fetchOffset

        self.frc = NSFetchedResultsController(
            fetchRequest: ResultType.fetchRequest(
                filter: filter,
                sort: sort,
                fetchLimit: fetchLimit,
                fetchOffset: fetchOffset
            ),
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()
    }

    // MARK: Public

    /// Block notifying when an error has occurred during fetch
    public var fetchErrorHandler: ((any Error) -> Void)?

    /// The filter criteria used to determine which entities are fetched.
    /// Updating this property will trigger a new fetch.
    public var filter: ResultType.Filter? {
        didSet {
            performFetchIfNeeded()
        }
    }

    /// The sort criteria used to order the fetched entities.
    /// Updating this property will trigger a new fetch.
    public var sort: ResultType.Sort? {
        didSet {
            performFetchIfNeeded()
        }
    }

    /// The maximum number of entities to fetch.
    /// Updating this property will trigger a new fetch.
    public var fetchLimit: Int {
        didSet {
            performFetchIfNeeded()
        }
    }

    /// The offset for the fetch request, allowing for pagination.
    /// Updating this property will trigger a new fetch.
    public var fetchOffset: Int {
        didSet {
            performFetchIfNeeded()
        }
    }

    /// An array of the currently fetched entities, reflecting the latest data
    /// based on the applied filter and sort criteria.
    @MainActor public var fetchedObjects: [ResultType] {
        return frc.fetchedObjects ?? []
    }

    /// A Combine publisher that emits an array of fetched entities
    /// whenever the underlying data changes.
    public var fetchedObjectsPublisher: any Publisher<[ResultType], Never> {
        $diff.map { [frc] _ in
            frc.fetchedObjects ?? []
        }
    }

    /// Publisher vending only the identifiers for results, which are smaller and thread-safe.
    /// This is a less-expensive publisher which will still notify you whenever results change.
    public var diffPublisher: any Publisher<CollectionDifference<NSManagedObjectID>?, Never> {
        $diff
    }

    // MARK: API

    /// Starts the fetch operation and begins monitoring changes in the Core Data context.
    public func beginFetch() throws {
        // Reset state
        diff = nil

        // Activates underlying FRC monitoring for changes by setting delegate
        // https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller#overview
        frc.delegate = self
        try frc.performFetch()
    }

    /// Stops monitoring changes and pauses the fetch operation.
    public func endFetch() {
        // Pause underlying FRC by setting delegate to nil
        // https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller#overview
        frc.delegate = nil
    }

    // MARK: NSFetchedResultsControllerDelegate

    public nonisolated func controller(
        _: NSFetchedResultsController<any NSFetchRequestResult>,
        didChangeContentWith diff: CollectionDifference<NSManagedObjectID>
    ) {
        Task { @MainActor in
            self.diff = diff
        }
    }

    // MARK: Private

    // MARK: Private Properties

    /// Context with objects to search
    private let moc: NSManagedObjectContext
    /// Controller fetching Core Data objects
    private let frc: NSFetchedResultsController<ResultType>

    /// Results of fetch request
    @Published private var diff: CollectionDifference<NSManagedObjectID>? = nil

    // MARK: Private Methods

    /// Apply updated configuration to fetch request
    private func updateFetchRequest() {
        frc.fetchRequest.predicate = filter?.predicate
        frc.fetchRequest.sortDescriptors = sort?.sortDescriptors ?? []
        frc.fetchRequest.fetchLimit = fetchLimit
        frc.fetchRequest.fetchOffset = fetchOffset
    }

    /// Execute fetch request with latest configuration
    private func performFetchIfNeeded() {
        updateFetchRequest()
        do {
            try beginFetch()
        } catch {
            fetchErrorHandler?(error)
        }
    }
}
