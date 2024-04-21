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

    public var predicate: NSPredicate? {
        switch self {

        case .maximumAge(let maximumAge):
            let minimumDate = Date.now.addingTimeInterval(Double(-365 * 60 * 60 * maximumAge))
            return NSPredicate(format: "%K >= %@", #keyPath(Person.birthdate), minimumDate as CVarArg)

        case .minimumAge(let minimumAge):
            let maximumDate = Date.now.addingTimeInterval(Double(-365 * 60 * 60 * minimumAge))
            return NSPredicate(format: "%K <= %@", #keyPath(Person.birthdate), maximumDate as CVarArg)

        case .personID(let personID):
            return NSPredicate(format: "%K == %@", #keyPath(Person.personID), personID)
        }
    }
}
