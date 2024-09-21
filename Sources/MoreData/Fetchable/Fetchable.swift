// Copyright © 2024 Ambience Healthcare

import CoreData

// MARK: - Fetchable

/// # Fetchable
/// Protocol for Core Data entities which can be fetched with a fetch request.
/// Implementing `Fetchable` adds a bunch of useful helper methods to your managed entity class.
public protocol Fetchable: NSManagedObject {
    associatedtype Filter: Filtering
    associatedtype Sort: Sorting

    /// Name of entity model
    static var entityName: String { get }
}

// MARK: - Helpers
extension Fetchable {

    /// Finds all entities matching an optional predicate
    public static func all(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        moc: NSManagedObjectContext
    ) throws
        -> [Self]
    {
        let fetchRequest = fetchRequest(predicate: predicate)
        fetchRequest.sortDescriptors = sortDescriptors
        return try moc.fetch(fetchRequest)
    }

    /// Finds all entities matching a filter case
    @_disfavoredOverload
    public static func all(
        matching filter: Filter? = nil,
        sortedBy sort: Sort? = nil,
        moc: NSManagedObjectContext
    ) throws
        -> [Self]
    {
        try all(
            predicate: filter?.predicate,
            sortDescriptors: sort?.sortDescriptors ?? [],
            moc: moc
        )
    }

    /// Finds number of entities matching an optional predicate
    public static func count(
        matching predicate: NSPredicate? = nil,
        moc: NSManagedObjectContext
    ) throws
        -> Int
    {
        try moc.count(for: fetchRequest(predicate: predicate))
    }

    /// Finds number of entities matching a filter case
    public static func count(
        matching filter: Filter,
        moc: NSManagedObjectContext
    ) throws
        -> Int
    {
        try count(matching: filter.predicate, moc: moc)
    }

    /// Deletes all entities matching an optional predicate
    public static func deleteAll(
        predicate: NSPredicate? = nil,
        moc: NSManagedObjectContext
    ) throws {
        let entities = try all(predicate: predicate, moc: moc)
        for entity in entities {
            moc.delete(entity)
        }
    }

    /// Deletes all entities matching a filter case
    public static func deleteAll(
        matching filter: Filter,
        moc: NSManagedObjectContext
    ) throws {
        try deleteAll(predicate: filter.predicate, moc: moc)
    }

    /// Finds one entity matching an optional predicate
    public static func unique(
        predicate: NSPredicate?,
        moc: NSManagedObjectContext
    ) throws
        -> Self?
    {
        let results = try all(predicate: predicate, moc: moc)

        if results.count > 1 {
            throw FetchableError.tooManyResults(results.count)
        }

        return results.first
    }

    /// Finds one entity matching a filter case
    public static func unique(
        matching filter: Filter,
        moc: NSManagedObjectContext
    ) throws
        -> Self?
    {
        try unique(predicate: filter.predicate, moc: moc)
    }
}

// MARK: - FetchRequest Builders
extension Fetchable {

    /// Form `NSFetchRequest` for this entity, with optional predicate
    public static func fetchRequest(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        fetchLimit: Int? = nil,
        fetchOffset: Int? = nil
    )
        -> NSFetchRequest<Self>
    {
        let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        if let fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        if let fetchOffset {
            fetchRequest.fetchOffset = fetchOffset
        }
        return fetchRequest
    }

    /// Form `NSFetchRequest` for this entity, with optional predicate
    public static func fetchRequest(
        filter: Filter? = nil,
        sort: Sort? = nil,
        fetchLimit: Int? = nil,
        fetchOffset: Int? = nil
    )
        -> NSFetchRequest<Self>
    {
        fetchRequest(
            predicate: filter?.predicate,
            sortDescriptors: sort?.sortDescriptors ?? [],
            fetchLimit: fetchLimit,
            fetchOffset: fetchOffset
        )
    }
}

// MARK: - FetchableError

enum FetchableError: Error {
    /// Thrown when more results are found than were expected
    case tooManyResults(Int)
}

// MARK: - FetchConfiguration

/// Configuration options for fetch request
public struct FetchConfiguration<Result: Fetchable> {
    public var filter: Result.Filter?
    public var sort: Result.Sort?
}
