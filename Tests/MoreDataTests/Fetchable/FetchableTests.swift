import XCTest
import CoreData
@testable import MoreData

final class FetchableTests: XCTestCase {

    var moc: NSManagedObjectContext!

    @MainActor
    override func setUpWithError() throws {
        moc = try makeInMemoryViewContext()
    }

    override func tearDownWithError() throws {
        moc = nil
    }

    func testAllEntitiesFetch() throws {
        // Given
        let entity1 = TestEntity(context: moc)
        entity1.name = "Alice"

        let entity2 = TestEntity(context: moc)
        entity2.name = "Bob"

        try moc.save()

        // When
        let fetchedEntities = try TestEntity.all(moc: moc)

        // Then
        XCTAssertEqual(fetchedEntities.count, 2)
        XCTAssertTrue(fetchedEntities.contains { $0.name == "Alice" })
        XCTAssertTrue(fetchedEntities.contains { $0.name == "Bob" })
    }

    func testFetchWithPredicate() throws {
        // Given
        let entity = TestEntity(context: moc)
        entity.name = "Alice"

        try moc.save()

        // When
        let predicate = NSPredicate(format: "name == %@", "Alice")
        let fetchedEntities = try TestEntity.all(predicate: predicate, moc: moc)

        // Then
        XCTAssertEqual(fetchedEntities.count, 1)
        XCTAssertEqual(fetchedEntities.first?.name, "Alice")
    }

    func testFetchSortedByName() throws {
        // Given
        let entity1 = TestEntity(context: moc)
        entity1.name = "Charlie"

        let entity2 = TestEntity(context: moc)
        entity2.name = "Betty"

        let entity3 = TestEntity(context: moc)
        entity3.name = "Alice"

        try moc.save()

        // When
        let sortedEntities = try TestEntity.all(
            sortedBy: .nameAscending,
            moc: moc
        )

        // Then
        XCTAssertEqual(sortedEntities.map { $0.name }, ["Alice", "Betty", "Charlie"])
    }

    func testCountEntities() throws {
        // Given
        let entity1 = TestEntity(context: moc)
        entity1.name = "Alice"

        let entity2 = TestEntity(context: moc)
        entity2.name = "Bob"

        try moc.save()

        // When
        let count = try TestEntity.count(moc: moc)

        // Then
        XCTAssertEqual(count, 2)
    }

    func testDeleteAllEntities() throws {
        // Given
        let entity = TestEntity(context: moc)
        entity.name = "Alice"

        try moc.save()

        // When
        try TestEntity.deleteAll(moc: moc)
        let remainingEntities = try TestEntity.all(moc: moc)

        // Then
        XCTAssertTrue(remainingEntities.isEmpty)
    }

    func testUniqueEntityFetch() throws {
        // Given
        let entity = TestEntity(context: moc)
        entity.name = "UniqueEntity"

        try moc.save()

        // When
        let fetchedEntity = try TestEntity.unique(predicate: NSPredicate(format: "name == %@", "UniqueEntity"), moc: moc)

        // Then
        XCTAssertNotNil(fetchedEntity)
        XCTAssertEqual(fetchedEntity?.name, "UniqueEntity")
    }

    func testUniqueEntityFetchTooManyResults() throws {
        // Given
        let entity1 = TestEntity(context: moc)
        entity1.name = "DuplicateEntity"

        let entity2 = TestEntity(context: moc)
        entity2.name = "DuplicateEntity"

        try moc.save()

        // When/Then
        XCTAssertThrowsError(try TestEntity.unique(predicate: NSPredicate(format: "name == %@", "DuplicateEntity"), moc: moc)) { error in
            guard case FetchableError.tooManyResults(let count) = error else {
                return XCTFail("Expected tooManyResults error, got \(error)")
            }
            XCTAssertEqual(count, 2)
        }
    }
}
