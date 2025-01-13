import CoreData
import MoreData

/// Helper function to make an in-memory moc for unit tests
@MainActor
func makeInMemoryViewContext() throws -> NSManagedObjectContext {
    let managedObjectModel = NSManagedObjectModel.makeTestModel()
    let controller = try CoreDataPersistenceController(
        config: .init(persistenceType: .inMemory),
        managedObjectModel: managedObjectModel,
        name: "MoreDataTests"
    )
    try controller.load()
    return controller.viewContext
}
