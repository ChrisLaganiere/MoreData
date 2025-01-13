import CoreData
import XCTest
@testable import MoreData

final class CoreDataPersistenceControllerTests: XCTestCase {

    var sut: CoreDataPersistenceController!
    var managedObjectModel: NSManagedObjectModel!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Initialize the managed object model
        managedObjectModel = NSManagedObjectModel.makeTestModel()
        XCTAssertNotNil(managedObjectModel, "Managed Object Model could not be loaded.")
    }

    override func tearDownWithError() throws {
        sut = nil
        managedObjectModel = nil

        try super.tearDownWithError()
    }

    func testInitInMemoryConfiguration() throws {
        sut = try CoreDataPersistenceController(
            config: .init(persistenceType: .inMemory),
            managedObjectModel: managedObjectModel,
            name: "MoreDataTests"
        )

        let storeDescription = sut.persistentContainer.persistentStoreDescriptions.first
        XCTAssertEqual(storeDescription?.url?.absoluteString, "file:///dev/null")
    }

    func testInitWithCustomURLConfiguration() throws {
        let customURL = URL(fileURLWithPath: "/tmp/test.sqlite")
        sut = try CoreDataPersistenceController(
            config: .init(persistenceType: .url(customURL)),
            managedObjectModel: managedObjectModel,
            name: "MoreDataTests"
        )

        let storeDescription = sut.persistentContainer.persistentStoreDescriptions.first
        XCTAssertEqual(storeDescription?.url, customURL)
    }

    func testInitWithDefaultURLConfiguration() throws {
        sut = try CoreDataPersistenceController(
            config: .init(persistenceType: .defaultURL),
            managedObjectModel: managedObjectModel,
            name: "MoreDataTests"
        )

        let storeDescription = sut.persistentContainer.persistentStoreDescriptions.first
        XCTAssertNotNil(storeDescription?.url)
        XCTAssertNoThrow(try sut.load())
    }

    @MainActor
    func testLoadPersistentStores() throws {
        sut = try CoreDataPersistenceController(
            config: .init(persistenceType: .inMemory),
            managedObjectModel: managedObjectModel,
            name: "MoreDataTests"
        )

        XCTAssertNoThrow(try sut.load())

        let storeDescription = sut.viewContext.persistentStoreCoordinator?.persistentStores.first
        XCTAssertNotNil(storeDescription, "Persistent store should be loaded")
    }

    func testLoadPersistentStoresFailure() throws {
        // Simulate a failure by providing an invalid URL
        let invalidURL = URL(fileURLWithPath: "/invalid/path/test.sqlite")
        sut = try CoreDataPersistenceController(
            config: .init(persistenceType: .url(invalidURL)),
            managedObjectModel: managedObjectModel,
            name: "MoreDataTests"
        )

        XCTAssertThrowsError(try sut.load(), "Loading should fail due to an invalid URL")
    }

    func testPerformBackgroundTask() throws {
        sut = try CoreDataPersistenceController(
            config: .init(persistenceType: .inMemory),
            managedObjectModel: managedObjectModel,
            name: "MoreDataTests"
        )
        try sut.load()

        let expectation = expectation(description: "Background task should complete")

        sut.performBackgroundTask { context in
            XCTAssertFalse(context.concurrencyType == .mainQueueConcurrencyType)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testNewBackgroundContextMergePolicy() throws {
        sut = try CoreDataPersistenceController(
            config: .init(persistenceType: .inMemory),
            managedObjectModel: managedObjectModel,
            name: "MoreDataTests"
        )

        let backgroundContext = sut.newBackgroundContext(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        XCTAssertEqual(
            (backgroundContext.mergePolicy as? NSMergePolicy)?.mergeType,
            .mergeByPropertyObjectTrumpMergePolicyType
        )
    }

    func testPerformBackgroundTaskAsync() async throws {
        sut = try CoreDataPersistenceController(
            config: .init(persistenceType: .inMemory),
            managedObjectModel: managedObjectModel,
            name: "MoreDataTests"
        )
        try sut.load()

        let result = await sut.performBackgroundTask { context -> Bool in
            XCTAssertFalse(context.concurrencyType == .mainQueueConcurrencyType)
            return true
        }

        XCTAssertTrue(result)
    }
}
