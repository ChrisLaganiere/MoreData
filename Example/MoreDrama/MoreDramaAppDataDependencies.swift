import CoreData
import MoreData

/// Data services which make the app go
@MainActor
final class MoreDramaAppDataDependencies {

    /// Controller of persistent app cache
    let persistenceController: CoreDataPersistenceController

    /// Generate sample data in db!
    let mockDataGenerator: MockDataGenerator

    init(persistenceController: CoreDataPersistenceController) {
        self.persistenceController = persistenceController
        mockDataGenerator = .init(persistenceController: persistenceController)
    }

    /// Do initial set up as required for dependencies
    func setUp() throws {
        try persistenceController.load()
        mockDataGenerator.startGenerating()
    }
}

// MARK: Available configurations
extension MoreDramaAppDataDependencies {

    // Here is an easy spot to provide different configurations for the app.
    // You might set up different debug situations here by mocking out various
    // services. Since they are all referenced by protocol, any part of the app
    // can be mocked here for any purpose.

    /// Configuration for production apps connecting to server
    static func `default`() -> MoreDramaAppDataDependencies {

        let persistenceController = try! CoreDataPersistenceController(
            name: "AmbientRecordingApp"
        )

        return MoreDramaAppDataDependencies(
            persistenceController: persistenceController
        )
    }

    /// Configuration for production apps connecting to server
    static func preview() -> MoreDramaAppDataDependencies {

        let persistenceController = try! CoreDataPersistenceController(
            config: .init(persistenceType: .inMemory),
            name: "AmbientRecordingApp-Preview"
        )

        return MoreDramaAppDataDependencies(
            persistenceController: persistenceController
        )
    }
}
