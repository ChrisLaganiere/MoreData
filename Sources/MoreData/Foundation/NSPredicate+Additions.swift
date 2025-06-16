import Foundation

/// Useful Swifty wrappers for NSPredicate
///
/// See cheatsheet when adding changes: https://kapeli.com/cheat_sheets/NSPredicate.docset/Contents/Resources/Documents/index
extension NSPredicate {

    // MARK: Strings and other objects

    public static func `is`<T>(_ keyPath: KeyPath<some Any, T>, value: T) -> NSPredicate where T: CVarArg {
        return NSPredicate(format: "%K == %@", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func `is`<T>(_ keyPath: KeyPath<some Any, T?>, value: T?) -> NSPredicate where T: CVarArg {
        if let value = value {
            return NSPredicate(format: "%K == %@", NSExpression(forKeyPath: keyPath).keyPath, value)
        } else {
            return NSPredicate(format: "%K == nil", NSExpression(forKeyPath: keyPath).keyPath)
        }
    }

    public static func isNot<T>(_ keyPath: KeyPath<some Any, T>, value: T) -> NSPredicate where T: CVarArg {
        return NSPredicate(format: "%K != %@", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func isNot<T>(_ keyPath: KeyPath<some Any, T?>, value: T?) -> NSPredicate where T: CVarArg {
        if let value = value {
            return NSPredicate(format: "%K != %@", NSExpression(forKeyPath: keyPath).keyPath, value)
        } else {
            return NSPredicate(format: "%K != nil", NSExpression(forKeyPath: keyPath).keyPath)
        }
    }

    public static func isNil<T>(_ keyPath: KeyPath<some Any, T?>) -> NSPredicate {
        NSPredicate(format: "%K == nil", NSExpression(forKeyPath: keyPath).keyPath)
    }

    public static func isNotNil<T>(_ keyPath: KeyPath<some Any, T?>) -> NSPredicate {
        NSPredicate(format: "%K != nil", NSExpression(forKeyPath: keyPath).keyPath)
    }

    // MARK: Strings

    public static func contains(_ keyPath: KeyPath<some Any, String>, substring: String, caseInsensitive: Bool = false) -> NSPredicate {
        let option = caseInsensitive ? "[c]" : ""
        return NSPredicate(format: "%K CONTAINS\(option) %@", NSExpression(forKeyPath: keyPath).keyPath, substring)
    }

    public static func contains(_ keyPath: KeyPath<some Any, String?>, substring: String, caseInsensitive: Bool = false) -> NSPredicate {
        let option = caseInsensitive ? "[c]" : ""
        return NSPredicate(format: "%K CONTAINS\(option) %@", NSExpression(forKeyPath: keyPath).keyPath, substring)
    }

    public static func beginsWith(_ keyPath: KeyPath<some Any, String>, prefix: String, caseInsensitive: Bool = false) -> NSPredicate {
        let option = caseInsensitive ? "[c]" : ""
        return NSPredicate(format: "%K BEGINSWITH\(option) %@", NSExpression(forKeyPath: keyPath).keyPath, prefix)
    }

    public static func beginsWith(_ keyPath: KeyPath<some Any, String?>, prefix: String, caseInsensitive: Bool = false) -> NSPredicate {
        let option = caseInsensitive ? "[c]" : ""
        return NSPredicate(format: "%K BEGINSWITH\(option) %@", NSExpression(forKeyPath: keyPath).keyPath, prefix)
    }

    public static func endsWith(_ keyPath: KeyPath<some Any, String>, suffix: String, caseInsensitive: Bool = false) -> NSPredicate {
        let option = caseInsensitive ? "[c]" : ""
        return NSPredicate(format: "%K ENDSWITH\(option) %@", NSExpression(forKeyPath: keyPath).keyPath, suffix)
    }

    public static func endsWith(_ keyPath: KeyPath<some Any, String?>, suffix: String, caseInsensitive: Bool = false) -> NSPredicate {
        let option = caseInsensitive ? "[c]" : ""
        return NSPredicate(format: "%K ENDSWITH\(option) %@", NSExpression(forKeyPath: keyPath).keyPath, suffix)
    }

    // MARK: Booleans

    public static func `is`(_ keyPath: KeyPath<some Any, Bool>, _ bool: Bool) -> NSPredicate {
        NSPredicate(format: "%K == %@", NSExpression(forKeyPath: keyPath).keyPath, NSNumber(booleanLiteral: bool))
    }

    // MARK: Integers

    public static func equalTo(_ keyPath: KeyPath<some Any, Int>, value: Int) -> NSPredicate {
        NSPredicate(format: "%K == %ld", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func greaterThan(_ keyPath: KeyPath<some Any, Int>, value: Int) -> NSPredicate {
        NSPredicate(format: "%K > %ld", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func lessThan(_ keyPath: KeyPath<some Any, Int>, value: Int) -> NSPredicate {
        NSPredicate(format: "%K < %ld", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func greaterThanOrEqualTo(_ keyPath: KeyPath<some Any, Int>, value: Int) -> NSPredicate {
        NSPredicate(format: "%K >= %ld", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func lessThanOrEqualTo(_ keyPath: KeyPath<some Any, Int>, value: Int) -> NSPredicate {
        NSPredicate(format: "%K <= %ld", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func between(_ keyPath: KeyPath<some Any, Int>, lowerBound: Int, upperBound: Int) -> NSPredicate {
        NSPredicate(format: "%K BETWEEN {%ld, %ld}", NSExpression(forKeyPath: keyPath).keyPath, lowerBound, upperBound)
    }

    // MARK: Collections

    public static func contains<T: CVarArg>(_ keyPath: KeyPath<some Any, NSSet>, element: T) -> NSPredicate {
        NSPredicate(format: "%K CONTAINS %@", NSExpression(forKeyPath: keyPath).keyPath, element)
    }

    public static func contains<T: CVarArg>(_ keyPath: KeyPath<some Any, NSSet?>, element: T) -> NSPredicate {
        NSPredicate(format: "%K CONTAINS %@", NSExpression(forKeyPath: keyPath).keyPath, element)
    }

    public static func `in`<T>(_ keyPath: KeyPath<some Any, T>, values: Set<T>) -> NSPredicate {
        NSPredicate(format: "%K IN %@", NSExpression(forKeyPath: keyPath).keyPath, values)
    }

    public static func `in`<T>(_ keyPath: KeyPath<some Any, T>, values: [T]) -> NSPredicate {
        NSPredicate(format: "%K IN %@", NSExpression(forKeyPath: keyPath).keyPath, values)
    }

    public static func `in`<T>(_ keyPath: KeyPath<some Any, T?>, values: Set<T>) -> NSPredicate {
        NSPredicate(format: "%K IN %@", NSExpression(forKeyPath: keyPath).keyPath, values)
    }

    public static func `in`<T>(_ keyPath: KeyPath<some Any, T?>, values: [T]) -> NSPredicate {
        NSPredicate(format: "%K IN %@", NSExpression(forKeyPath: keyPath).keyPath, values)
    }

    // MARK: Dates

    public static func before(_ keyPath: KeyPath<some Any, Date?>, date: Date) -> NSPredicate {
        NSPredicate(format: "%K < %@", NSExpression(forKeyPath: keyPath).keyPath, date as NSDate)
    }

    public static func after(_ keyPath: KeyPath<some Any, Date?>, date: Date) -> NSPredicate {
        NSPredicate(format: "%K > %@", NSExpression(forKeyPath: keyPath).keyPath, date as NSDate)
    }

    public static func between(_ keyPath: KeyPath<some Any, Date?>, startDate: Date, endDate: Date) -> NSPredicate {
        NSPredicate(format: "%K BETWEEN {%@, %@}", NSExpression(forKeyPath: keyPath).keyPath, startDate as NSDate, endDate as NSDate)
    }

    // MARK: Aggregates

    public static func all() -> NSPredicate {
        NSPredicate(value: true)
    }

    public static func all(_ predicates: [NSPredicate]) -> NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    public static func any(_ predicates: [NSPredicate]) -> NSPredicate {
        NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }

    public static func none() -> NSPredicate {
        NSPredicate(value: false)
    }

    public static func not(_ predicate: NSPredicate) -> NSPredicate {
        NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
    }
}
