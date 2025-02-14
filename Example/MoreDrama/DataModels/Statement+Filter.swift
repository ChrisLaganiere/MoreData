import CoreData
import MoreData

extension Statement {
    public typealias Filter = StatementFilter
}

/// Filters which specify particular entities to fetch
public enum StatementFilter: Filtering {

    /// Matching content
    case content(String)

    /// Look up subtext
    case statementContains(String)

    /// relation to particular individual
    case toldBy(Person)
    case toldTo(Person)

    /// compound predicate
    case all([StatementFilter])
    case noElements

    public var predicate: NSPredicate {
        switch self {

        case .content(let content):
            return .is(\Statement.content, value: content)

        case .statementContains(let query):
            return .contains(\Statement.content, substring: query, caseInsensitive: true)

        case .toldBy(let person):
            return .is(\Statement.by, value: person)

        case .toldTo(let person):
            return .contains(\Statement.to, element: person)

        case .all(let filters):
            return NSCompoundPredicate(andPredicateWithSubpredicates: filters.compactMap(\.predicate))

        case .noElements:
            return .none()
        }
    }

    /// Helper for cases where you don't have person records indexed
    static func toldBy(_ personID: String, in people: any Collection<Person>) -> StatementFilter {
        guard let person = people.first(where: { $0.personID == personID }) else {
            return .noElements
        }
        return .toldBy(person)
    }
}
