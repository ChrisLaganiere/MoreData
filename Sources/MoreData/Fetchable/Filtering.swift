import CoreData

/**
 # Filtering
 Protocol for Core Data filters which specify particular entities to fetch.
 */
public protocol Filtering: Equatable {
    var predicate: NSPredicate? { get }
}

// MARK: - Helpers
public extension Filtering {

    /// Require match of all subpredicates
    static func all(_ predicates: [NSPredicate?]) -> NSPredicate? {
        NSCompoundPredicate(
            andPredicateWithSubpredicates: predicates.compactMap {
                $0
            }
        )
    }

    /// Require match of all subpredicates
    static func all(_ filters: [Self]) -> NSPredicate? {
        all(filters.map({ $0.predicate }))
    }

    /// Require match of at least one subpredicate
    static func any(_ predicates: [NSPredicate?]) -> NSPredicate? {
        NSCompoundPredicate(
            orPredicateWithSubpredicates: predicates.compactMap {
                $0
            }
        )
    }

    /// Require match of at least one subpredicate
    static func any(_ filters: [Self]) -> NSPredicate? {
        any(filters.map({ $0.predicate }))
    }

    /// Require match of at least one subpredicate
    static func by(_ filter: Self) -> NSPredicate? {
        filter.predicate
    }

    /// Inverse a predicate
    static func not(_ predicate: NSPredicate?) -> NSPredicate? {
        guard let predicate else {
            return nil
        }
        return NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
    }

    /// Inverse a filter
    static func not(_ filter: Self) -> NSPredicate? {
        not(filter.predicate)
    }

}
