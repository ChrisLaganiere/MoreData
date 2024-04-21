import XCTest
import CoreData
@testable import MoreData

final class FilteringTests: XCTestCase {

    func testAllPredicates() {
        // Given
        let nameFilter = TestEntityFilter.nameContains("Alice")
        let ageFilter = TestEntityFilter.ageGreaterThan(25)

        // When
        let allPredicate = TestEntityFilter.all([nameFilter, ageFilter])

        // Then
        XCTAssertEqual(allPredicate?.predicateFormat, "name CONTAINS[cd] \"Alice\" AND age > 25")
    }

    func testAllFilters() {
        // Given
        let filters: [TestEntityFilter] = [
            .nameContains("Alice"),
            .ageGreaterThan(25),
            .isActive(true)
        ]

        // When
        let allPredicate = TestEntityFilter.all(filters)

        // Then
        XCTAssertEqual(allPredicate?.predicateFormat, "name CONTAINS[cd] \"Alice\" AND age > 25 AND isActive == 1")
    }

    func testAnyPredicates() {
        // Given
        let nameFilter = TestEntityFilter.nameContains("Alice")
        let ageFilter = TestEntityFilter.ageGreaterThan(25)

        // When
        let anyPredicate = TestEntityFilter.any([nameFilter.predicate, ageFilter.predicate])

        // Then
        XCTAssertEqual(anyPredicate?.predicateFormat, "name CONTAINS[cd] \"Alice\" OR age > 25")
    }

    func testAnyFilters() {
        // Given
        let filters: [TestEntityFilter] = [
            .nameContains("Alice"),
            .ageGreaterThan(25),
            .isActive(true)
        ]

        // When
        let anyPredicate = TestEntityFilter.any(filters)

        // Then
        XCTAssertEqual(anyPredicate?.predicateFormat, "name CONTAINS[cd] \"Alice\" OR age > 25 OR isActive == 1")
    }

    func testByFilter() {
        // Given
        let filter = TestEntityFilter.nameContains("Alice")

        // When
        let predicate = TestEntityFilter.by(filter)

        // Then
        XCTAssertEqual(predicate?.predicateFormat, "name CONTAINS[cd] \"Alice\"")
    }

    func testNotPredicate() {
        // Given
        let filter = TestEntityFilter.nameContains("Alice")

        // When
        let notPredicate = TestEntityFilter.not(filter.predicate)

        // Then
        XCTAssertEqual(notPredicate?.predicateFormat, "NOT name CONTAINS[cd] \"Alice\"")
    }

    func testNotFilter() {
        // Given
        let filter = TestEntityFilter.isActive(true)

        // When
        let notPredicate = TestEntityFilter.not(filter)

        // Then
        XCTAssertEqual(notPredicate?.predicateFormat, "NOT isActive == 1")
    }
}
