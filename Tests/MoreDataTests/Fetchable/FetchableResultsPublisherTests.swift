import XCTest
import CoreData
import Combine
@testable import MoreData

@MainActor
final class FetchableResultsPublisherTests: XCTestCase {

    var controller: CoreDataPersisting!
    var moc: NSManagedObjectContext!
    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Initialize the managed object model
        let managedObjectModel = NSManagedObjectModel.makeTestEntityModel()

        // Initialize Core Data stack
        let controller = try CoreDataPersistenceController(
            config: .inMemory,
            name: "TestEntityModel",
            managedObjectModel: managedObjectModel
        )
        try controller.load()
        self.controller = controller

        moc = controller.viewContext
    }

    override func tearDownWithError() throws {
        controller = nil
        cancellables.removeAll()

        try super.tearDownWithError()
    }

    // MARK: Helpers

    // Helper to create a TestEntity
    @discardableResult
    private func createTestEntity(name: String = "Alice", isActive: Bool = true) -> TestEntity {
        let entity = TestEntity(context: moc)
        entity.name = name
        entity.isActive = isActive
        return entity
    }

    // MARK: Tests

    func testInitialization() {
        let publisher = FetchableResultsPublisher<TestEntity>(
            filter: .nameContains("Alice"),
            sort: .nameAscending,
            moc: moc
        )

        XCTAssertNotNil(publisher)
        XCTAssertEqual(publisher.filter, .nameContains("Alice"))
    }

    func testFetchingObjects() throws {
        // Insert sample data
        let entity1 = createTestEntity(name: "Alice", isActive: true)
        createTestEntity(name: "Bob", isActive: false)
        try moc.save()

        // Create publisher
        let publisher = FetchableResultsPublisher<TestEntity>(
            filter: nil,
            sort: .nameAscending,
            moc: moc
        )

        let expectation = XCTestExpectation(description: "Fetched objects updated")

        publisher.fetchedObjectsPublisher
            .sink { fetchedObjects in
                if fetchedObjects.count == 2, fetchedObjects.first?.name == entity1.name {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        try publisher.beginFetch()

        wait(for: [expectation], timeout: 1.0)
    }

    func testDynamicFilterUpdate() throws {
        // Insert sample data
        createTestEntity(name: "Alice", isActive: true)
        createTestEntity(name: "Bob", isActive: false)
        try moc.save()

        // Create publisher
        let publisher = FetchableResultsPublisher<TestEntity>(
            filter: .nameContains("Alice"),
            sort: .nameAscending,
            moc: moc
        )

        let expectation = XCTestExpectation(description: "Dynamic filter update")

        try publisher.beginFetch()

        publisher.fetchedObjectsPublisher
            .sink { fetchedObjects in
                if fetchedObjects.count == 1 {
                    XCTAssertEqual(fetchedObjects.first?.name, "Alice")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        cancellables.removeAll()

        // Update filter dynamically
        publisher.filter = .nameContains("Bob")

        let expectation2 = XCTestExpectation(description: "Fetched objects updated with new filter")

        publisher.fetchedObjectsPublisher
            .sink { fetchedObjects in
                if fetchedObjects.count == 1 {
                    XCTAssertEqual(fetchedObjects.first?.name, "Bob")
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation2], timeout: 1.0)
    }

    func testDiffPublisher() throws {
        // Insert sample data
        createTestEntity(name: "Alice", isActive: true)
        try moc.save()

        // Create publisher
        let publisher = FetchableResultsPublisher<TestEntity>(
            filter: nil,
            sort: nil,
            moc: moc
        )

        let expectation = XCTestExpectation(description: "DiffPublisher emitted a value")

        publisher.diffPublisher
            .sink { diff in
                if let diff = diff, diff.insertions.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        try publisher.beginFetch()

        wait(for: [expectation], timeout: 1.0)
    }
}
