// Copyright © 2024 Ambience Healthcare

import CoreData

// MARK: - CoreDataPersisting

/// # CoreDataPersisting
/// Protocol for app data layer persistence controller.
/// You must call `load()` before making use of controller.
public protocol CoreDataPersisting {

    /// A context where entities live, for use displaying views on the main thread.
    /// Use this to read data for building features!
    @MainActor var viewContext: NSManagedObjectContext { get }

    /// Perform actions with a private-queue managed object context that loads into persistent store
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)

    /// Perform actions with a private-queue managed object context that feeds into persistent store (async)
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async rethrows -> T

    /// Build writing context for persistent container that can be used in a private background worker thread.
    func newBackgroundContext(merge: NSMergePolicyType) -> NSManagedObjectContext
}

// MARK: Helpers
extension CoreDataPersisting {
    /// Build writing context for persistent container that can be used in a private background worker thread.
    /// (With default merge policy: `.mergeByPropertyStoreTrumpMergePolicyType`)
    public func newBackgroundContext() -> NSManagedObjectContext {
        newBackgroundContext(merge: .mergeByPropertyStoreTrumpMergePolicyType)
    }
}
