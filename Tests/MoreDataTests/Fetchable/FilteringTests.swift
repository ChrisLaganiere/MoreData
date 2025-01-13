import CoreData
import XCTest
@testable import MoreData

final class FilteringTests: XCTestCase {

    func testAllFilters() {
        // Given
        let filters: [PersonFilter] = [
            .nameContains("Alice"),
            .isActive(true),
        ]

        // When
        let allPredicate = PersonFilter.all(filters)

        // Then
        XCTAssertEqual(allPredicate.predicateFormat, "name CONTAINS \"Alice\" AND isActive == 1")
    }

    func testAnyFilters() {
        // Given
        let filters: [PersonFilter] = [
            .nameContains("Alice"),
            .isActive(true),
        ]

        // When
        let anyPredicate = PersonFilter.any(filters)

        // Then
        XCTAssertEqual(anyPredicate.predicateFormat, "name CONTAINS \"Alice\" OR isActive == 1")
    }

    func testByFilter() {
        // Given
        let filter = PersonFilter.nameContains("Alice")

        // When
        let predicate = PersonFilter.by(filter)

        // Then
        XCTAssertEqual(predicate.predicateFormat, "name CONTAINS \"Alice\"")
    }

    func testNotFilter() {
        // Given
        let filter = PersonFilter.isActive(true)

        // When
        let notPredicate = PersonFilter.not(filter)

        // Then
        XCTAssertEqual(notPredicate.predicateFormat, "NOT isActive == 1")
    }
}
