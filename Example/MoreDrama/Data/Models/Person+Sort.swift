import CoreData
import MoreData

/// Sort descriptors which specify how to sort fetched results
public enum PersonSort: Sorting {

    /// Sort by age
    case youngest
    case oldest
    /// Sort by name, A-Z
    case name

    public var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .youngest:
            [
                NSSortDescriptor(keyPath: \Person.birthdate, ascending: false),
                // Fall back to ensure consistent sort order
                NSSortDescriptor(keyPath: \Person.name, ascending: true),
            ]
        case .oldest:
            [
                NSSortDescriptor(keyPath: \Person.birthdate, ascending: true),
                // Fall back to ensure consistent sort order
                NSSortDescriptor(keyPath: \Person.name, ascending: true),
            ]
        case .name:
            [
                NSSortDescriptor(keyPath: \Person.name, ascending: true),
                // Fall back to ensure consistent sort order
                NSSortDescriptor(keyPath: \Person.birthdate, ascending: false),
            ]
        }
    }
}
