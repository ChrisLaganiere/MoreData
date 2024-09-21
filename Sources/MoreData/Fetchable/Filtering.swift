// Copyright © 2024 Ambience Healthcare

import CoreData

// MARK: - Filtering

/// # Filtering
/// Protocol for Core Data filters which specify particular entities to fetch.
public protocol Filtering: Equatable {
    var predicate: NSPredicate? { get }
}

// MARK: - Helpers
extension Filtering {

    /// Require match of all subpredicates
    public static func all(_ predicates: [NSPredicate?]) -> NSPredicate? {
        NSCompoundPredicate(
            andPredicateWithSubpredicates: predicates.compactMap {
                $0
            }
        )
    }

    /// Require match of all subpredicates
    public static func all(_ filters: [Self]) -> NSPredicate? {
        all(filters.map(\.predicate))
    }

    /// Require match of at least one subpredicate
    public static func any(_ predicates: [NSPredicate?]) -> NSPredicate? {
        NSCompoundPredicate(
            orPredicateWithSubpredicates: predicates.compactMap {
                $0
            }
        )
    }

    /// Require match of at least one subpredicate
    public static func any(_ filters: [Self]) -> NSPredicate? {
        any(filters.map(\.predicate))
    }

    /// Require match of at least one subpredicate
    public static func by(_ filter: Self) -> NSPredicate? {
        filter.predicate
    }

    /// Inverse a predicate
    public static func not(_ predicate: NSPredicate?) -> NSPredicate? {
        guard let predicate else {
            return nil
        }
        return NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
    }

    /// Inverse a filter
    public static func not(_ filter: Self) -> NSPredicate? {
        not(filter.predicate)
    }

}
