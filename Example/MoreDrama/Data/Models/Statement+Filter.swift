import CoreData
import MoreData

/// Filters which specify particular entities to fetch
public enum StatementFilter: Filtering {

    /// Look up subtext
    case fuzzySearch(String)

    /// relation to particular individual
    case toldBy(Person)
    case toldTo(Person)

    public var predicate: NSPredicate? {
        switch self {

        case .fuzzySearch(let query):
            return NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Statement.content), query)

        case .toldBy(let person):
            return NSPredicate(format: "%K == %@", #keyPath(Statement.by), person)

        case .toldTo(let person):
            return NSPredicate(format: "%@ IN %K", #keyPath(Statement.to), person)
        }
    }
}
