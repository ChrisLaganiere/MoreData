import CoreData
import XCTest
@testable import MoreData

final class FilteringTests: XCTestCase {

    func testAllFilters() {
        // Given
        let filters: [TestEntityFilter] = [
            .nameContains("Alice"),
            .isActive(true),
        ]

        // When
        let allPredicate = TestEntityFilter.all(filters)

        // Then
        XCTAssertEqual(allPredicate.predicateFormat, "name CONTAINS \"Alice\" AND isActive == 1")
    }

    func testAnyFilters() {
        // Given
        let filters: [TestEntityFilter] = [
            .nameContains("Alice"),
            .isActive(true),
        ]

        // When
        let anyPredicate = TestEntityFilter.any(filters)

        // Then
        XCTAssertEqual(anyPredicate.predicateFormat, "name CONTAINS \"Alice\" OR isActive == 1")
    }

    func testByFilter() {
        // Given
        let filter = TestEntityFilter.nameContains("Alice")

        // When
        let predicate = TestEntityFilter.by(filter)

        // Then
        XCTAssertEqual(predicate.predicateFormat, "name CONTAINS \"Alice\"")
    }

    func testNotFilter() {
        // Given
        let filter = TestEntityFilter.isActive(true)

        // When
        let notPredicate = TestEntityFilter.not(filter)

        // Then
        XCTAssertEqual(notPredicate.predicateFormat, "NOT isActive == 1")
    }
}
