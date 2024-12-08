import CoreData
import MoreData

/// Filters which specify particular entities to fetch
public enum PersonFilter: Filtering {

    /// maximum age, in years
    case maximumAge(Int)
    /// minimum age, in years
    case minimumAge(Int)

    /// particular individual
    case personID(String)

    public var predicate: NSPredicate {
        switch self {

        case .maximumAge(let maximumAge):
            let minimumDate = Date.now.addingTimeInterval(Double(-365 * 60 * 60 * maximumAge))
            return .after(\Person.birthdate, date: minimumDate)

        case .minimumAge(let minimumAge):
            let maximumDate = Date.now.addingTimeInterval(Double(-365 * 60 * 60 * minimumAge))
            return .before(\Person.birthdate, date: maximumDate)

        case .personID(let personID):
            return .is(\Person.personID, value: personID)
        }
    }
}
