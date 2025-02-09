import XCTest

class NSPredicateExtensionsTests: XCTestCase {

    final class TestObject: NSObject {
        @objc var name: String?
        @objc var age: Int
        @objc var isActive: Bool
        @objc var createdAt: Date?
        @objc var strings: NSSet?

        init(
            name: String = "Shelster",
            age: Int = 26,
            isActive: Bool = false,
            createdAt: Date = .now,
            strings: NSSet = .init()
        ) {
            self.name = name
            self.age = age
            self.isActive = isActive
            self.createdAt = createdAt
            self.strings = strings
        }
    }

    // MARK: - Strings and Other Objects

    func testMatchingString() {
        let predicate = NSPredicate.is(\TestObject.name, value: "John")
        XCTAssertEqual(predicate.predicateFormat, "name == \"John\"")
    }

    func testNotString() {
        let predicate = NSPredicate.isNot(\TestObject.name, value: "John")
        XCTAssertEqual(predicate.predicateFormat, "name != \"John\"")
    }

    func testIsNil() {
        let predicate = NSPredicate.isNil(\TestObject.name)
        XCTAssertEqual(predicate.predicateFormat, "name == nil")
    }

    func testIsNotNil() {
        let predicate = NSPredicate.isNotNil(\TestObject.name)
        XCTAssertEqual(predicate.predicateFormat, "name != nil")
    }

    // MARK: - Strings

    func testContains() {
        let predicate = NSPredicate.contains(\TestObject.name, substring: "John")
        XCTAssertEqual(predicate.predicateFormat, "name CONTAINS \"John\"")
    }

    func testContainsCaseInsensitive() {
        let predicate = NSPredicate.contains(\TestObject.name, substring: "John", caseInsensitive: true)
        XCTAssertEqual(predicate.predicateFormat, "name CONTAINS[c] \"John\"")
    }

    func testBeginsWith() {
        let predicate = NSPredicate.beginsWith(\TestObject.name, prefix: "Jo")
        XCTAssertEqual(predicate.predicateFormat, "name BEGINSWITH \"Jo\"")
    }

    func testEndsWith() {
        let predicate = NSPredicate.endsWith(\TestObject.name, suffix: "hn")
        XCTAssertEqual(predicate.predicateFormat, "name ENDSWITH \"hn\"")
    }

    // MARK: - Booleans

    func testEqualToInt() {
        let predicate = NSPredicate.equalTo(\TestObject.age, value: 30)
        XCTAssertEqual(predicate.predicateFormat, "age == 30")
    }

    func testTrue() {
        let predicate = NSPredicate.is(\TestObject.isActive, true)
        XCTAssertEqual(predicate.predicateFormat, "isActive == 1")
    }

    func testFalse() {
        let predicate = NSPredicate.is(\TestObject.isActive, false)
        XCTAssertEqual(predicate.predicateFormat, "isActive == 0")
    }

    // MARK: - Integers

    func testGreaterThan() {
        let predicate = NSPredicate.greaterThan(\TestObject.age, value: 20)
        XCTAssertEqual(predicate.predicateFormat, "age > 20")
    }

    func testLessThan() {
        let predicate = NSPredicate.lessThan(\TestObject.age, value: 30)
        XCTAssertEqual(predicate.predicateFormat, "age < 30")
    }

    func testGreaterThanOrEqualTo() {
        let predicate = NSPredicate.greaterThanOrEqualTo(\TestObject.age, value: 25)
        XCTAssertEqual(predicate.predicateFormat, "age >= 25")
    }

    func testLessThanOrEqualTo() {
        let predicate = NSPredicate.lessThanOrEqualTo(\TestObject.age, value: 35)
        XCTAssertEqual(predicate.predicateFormat, "age <= 35")
    }

    func testBetweenInt() {
        let predicate = NSPredicate.between(\TestObject.age, lowerBound: 18, upperBound: 65)
        XCTAssertEqual(predicate.predicateFormat, "age BETWEEN {18, 65}")
    }

    // MARK: - Collections

    func testContainsInCollection() {
        let predicate = NSPredicate.contains(\TestObject.strings, element: "Lava")
        let testObject = TestObject()
        XCTAssertFalse(predicate.evaluate(with: testObject))

        let testObject2 = TestObject(strings: ["Lava"])
        XCTAssertTrue(predicate.evaluate(with: testObject2))
    }

    func testIn() {
        let predicate = NSPredicate.in(\TestObject.age, values: [18, 25, 30])
        XCTAssertEqual(predicate.predicateFormat, "age IN {18, 25, 30}")
    }

    func testInSet() {
        let predicate = NSPredicate.in(\TestObject.age, values: Set([18, 25, 30]))
        let testObject = TestObject(age: 27)
        XCTAssertFalse(predicate.evaluate(with: testObject))

        let testObject2 = TestObject(age: 25)
        XCTAssertTrue(predicate.evaluate(with: testObject2))
    }

    // MARK: - Dates

    func testAfter() {
        let pastDate = Date().addingTimeInterval(-1000) // 1000 seconds ago
        let futureDate = Date().addingTimeInterval(1000) // 1000 seconds in the future
        let now = Date()

        let testObject = TestObject(createdAt: now)

        let predicate = NSPredicate.after(\TestObject.createdAt, date: pastDate)

        // This should return true since "now" is after "pastDate"
        XCTAssertTrue(predicate.evaluate(with: testObject))

        // A different object where createdAt is in the past
        let oldObject = TestObject(createdAt: pastDate)

        // This should return false since "pastDate" is not after itself
        XCTAssertFalse(predicate.evaluate(with: oldObject))

        // This should return true since "futureDate" is after "now"
        let futureObject = TestObject(createdAt: futureDate)
        XCTAssertTrue(predicate.evaluate(with: futureObject))
    }

    func testBefore() {
        let pastDate = Date().addingTimeInterval(-1000) // 1000 seconds ago
        let futureDate = Date().addingTimeInterval(1000) // 1000 seconds in the future
        let now = Date()

        let testObject = TestObject(createdAt: now)

        let predicate = NSPredicate.before(\TestObject.createdAt, date: futureDate)

        // This should return true since "now" is before "futureDate"
        XCTAssertTrue(predicate.evaluate(with: testObject))

        // A different object where createdAt is in the future
        let futureObject = TestObject(createdAt: futureDate)

        // This should return false since "futureDate" is not before itself
        XCTAssertFalse(predicate.evaluate(with: futureObject))

        // This should return true since "pastDate" is before "now"
        let pastObject = TestObject(createdAt: pastDate)
        XCTAssertTrue(predicate.evaluate(with: pastObject))
    }

    func testBetweenDates() {
        let startDate = Date().addingTimeInterval(-1000) // 1000 seconds ago
        let endDate = Date().addingTimeInterval(1000) // 1000 seconds in the future
        let now = Date()

        let testObject = TestObject(createdAt: now)

        let predicate = NSPredicate.between(\TestObject.createdAt, startDate: startDate, endDate: endDate)

        // This should return true since "now" is between "startDate" and "endDate"
        XCTAssertTrue(predicate.evaluate(with: testObject))

        // A different object where createdAt is before startDate
        let oldObject = TestObject(createdAt: startDate.addingTimeInterval(-1))

        // This should return false since "createdAt" is before "startDate"
        XCTAssertFalse(predicate.evaluate(with: oldObject))

        // A different object where createdAt is after endDate
        let futureObject = TestObject(createdAt: endDate.addingTimeInterval(1))

        // This should return false since "createdAt" is after "endDate"
        XCTAssertFalse(predicate.evaluate(with: futureObject))
    }
}
