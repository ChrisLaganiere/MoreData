// Copyright © 2024 Ambience Healthcare

import Combine
import CoreData

/// # FetchableResultsPublishing
/// Protocol for a publisher which vends up-to-date entities matching filter and sort criteria.
/// Call `beginFetch()` and `endFetch()` to manage publisher life cycle.
@MainActor
public protocol FetchableResultsPublishing {

    /// Entity type to query for and observe
    associatedtype ResultType: Fetchable

    /// Which entities to fetch for
    var filter: ResultType.Filter? { get set }
    /// How results should be stored
    var sort: ResultType.Sort? { get set }

    /// Cache of last-known entities matching filter and sort
    @MainActor var fetchedObjects: [ResultType] { get }

    /// Publisher vending entities matching filter and sort
    var fetchedObjectsPublisher: any Publisher<[ResultType], Never> { get }
    /// Publisher vending only the identifiers for results, which are smaller and thread-safe.
    /// This is a less-expensive publisher which will still notify you whenever results change.
    var diffPublisher: any Publisher<CollectionDifference<NSManagedObjectID>?, Never> { get }

    /// Start fetching for results, and publish when fetched objects change
    func beginFetch() throws
    /// Pause fetching for results
    func endFetch()

}
