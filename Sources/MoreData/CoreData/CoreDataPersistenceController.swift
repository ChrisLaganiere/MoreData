import CoreData

// MARK: - CoreDataPersistenceController

/// # CoreDataPersistenceController
/// Sets up a persistent container for a Core Data stack.
public final class CoreDataPersistenceController: CoreDataPersisting {

    // MARK: Lifecycle

    /**
     - Parameter config: desired behavior of persistence controller
     - Parameter managedObjectModel: schema for entities that will be saved to persistent store
     - Parameter name: name of persistence controller, which distinguishes it from any other persistent stores, and is the default file name for SQLite backing file
     */
    public init(
        config: Configuration = .default,
        managedObjectModel: NSManagedObjectModel? = nil,
        name: String
    ) throws {
        guard let managedObjectModel = managedObjectModel ?? NSManagedObjectModel.mergedModel(
            from: [Bundle.main]
        ) else {
            throw CoreDataPersistenceControllerError.missingManagedObjectModel
        }

        let container = NSPersistentContainer(
            name: name,
            managedObjectModel: managedObjectModel
        )

        // Configure store description
        guard let description = container.persistentStoreDescriptions.first else {
            throw CoreDataPersistenceControllerError.missingPersistentStoreDescription
        }

        switch config.persistenceType {
        case .inMemory:
            description.url = URL(fileURLWithPath: "/dev/null")
        case .url(let url):
            description.url = url
        case .defaultURL:
            // NO-OP: No change needed
            break
        }

        // Setting necessary for CoreDataSpotlightDelegate and Swift Data interop
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        // Setting necessary for CoreDataSpotlightDelegate
        description.type = NSSQLiteStoreType

        self.managedObjectModel = managedObjectModel
        self.persistentContainer = container
    }

    // MARK: Public

    /// A context where entities live, for use displaying views on the main thread
    @MainActor public var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: API

    /// Set up controller. You must call this before making use of this controller.
    public func load() throws {
        // Load stores
        var loadError: NSError?

        persistentContainer.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                // Typical reasons for an error here include:
                // * The parent directory does not exist, cannot be created, or disallows writing.
                // * The persistent store is not accessible, due to permissions or data protection when the device is
                // locked.
                // * The device is out of space.
                // * The store could not be migrated to the current model version.
                // Check the error message to determine what the actual problem was.
                loadError = error
            }

            // Configure contexts to automatically merge changes from background worker contexts
            self?.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        }

        if let loadError {
            throw loadError
        }
    }

    /// Perform actions with a private-queue managed object context that loads into persistent store
    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let moc = backgroundWriteMoc
        moc.perform {
            block(moc)
        }
    }

    /// Perform actions with a private-queue managed object context that feeds into persistent store (async)
    public func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async rethrows -> T {
        let moc = backgroundWriteMoc
        return try await moc.perform {
            try block(moc)
        }
    }

    /// Build writing context for persistent container that can be used in a private background worker thread.
    public func newBackgroundContext(merge: NSMergePolicyType) -> NSManagedObjectContext {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy(merge: merge)
        return backgroundContext
    }

    // MARK: Internal

    /// Shared writer moc where write changes to store are serialized in a private worker queue.
    /// Write changes are serialized to avoid merge conflicts:
    /// https://stackoverflow.com/a/45206964
    lazy var backgroundWriteMoc = newBackgroundContext()

    // MARK: Private Properties

    /// Manager with responsibilities that cover fetching and saving entities in Core Data
    let persistentContainer: NSPersistentContainer

    /// Schema for entities that can live in persistent container.
    let managedObjectModel: NSManagedObjectModel

}

// MARK: - Definitions
extension CoreDataPersistenceController {
    /// Configuration options for persistence controller
    public struct Configuration {
        public enum PersistenceType {
            /// In-memory only; do not persist
            case inMemory
            /// Persist at custom location, with file URL
            case url(URL)
            /// Persist at default app location
            case defaultURL
        }

        public static let `default` = Self.init()

        /// Whether and where to save persistent data
        let persistenceType: PersistenceType

        public init(persistenceType: PersistenceType = .defaultURL) {
            self.persistenceType = persistenceType
        }
    }
}

/// Errors that can occur during persistence controller setup
public enum CoreDataPersistenceControllerError: String, Error, CustomDebugStringConvertible {
    case missingManagedObjectModel
    case missingPersistentStoreDescription

    public var debugDescription: String {
        switch self {
        case .missingManagedObjectModel:
            return "Missing managed object model. Typically this means you haven't added a managed object model to your project, or that the bundle provided to NSManagedObjectModel initializer is incorrect."
        case .missingPersistentStoreDescription:
            return "Missing persistent store description."
        }
    }
}
