import CoreData
import MoreData

/// Helper function to make an in-memory moc for unit tests
@MainActor
func makeInMemoryViewContext() throws -> NSManagedObjectContext {
    let managedObjectModel = NSManagedObjectModel.makeTestEntityModel()
    let controller = try CoreDataPersistenceController(config: .inMemory, name: "TestEntityModel", managedObjectModel: managedObjectModel)
    try controller.load()
    return controller.viewContext
}
