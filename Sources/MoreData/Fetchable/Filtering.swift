import CoreData

// MARK: - Filtering

/// # Filtering
/// Protocol for Core Data filters which specify particular entities to fetch.
public protocol Filtering: Equatable {
    var predicate: NSPredicate { get }
}

// MARK: - Helpers
extension Filtering {

    /// Require match of all subpredicates
    public static func all(_ filters: [Self]) -> NSPredicate {
        .all(filters.map(\.predicate))
    }

    /// Require match of at least one subpredicate
    public static func any(_ filters: [Self]) -> NSPredicate {
        .any(filters.map(\.predicate))
    }

    /// Require match of at least one subpredicate
    public static func by(_ filter: Self) -> NSPredicate {
        filter.predicate
    }

    /// Inverse a filter
    public static func not(_ filter: Self) -> NSPredicate {
        .not(filter.predicate)
    }

}
