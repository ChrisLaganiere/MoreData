import CoreData
@testable import MoreData

enum PersonFilter: Filtering {
    case nameContains(String)
    case isActive(Bool)

    var predicate: NSPredicate {
        switch self {
        case .nameContains(let name):
            return .contains(\Person.name, substring: name)
        case .isActive(let isActive):
            return .is(\Person.isActive, isActive)
        }
    }
}

enum PersonSort: Sorting {
    case nameAscending

    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .nameAscending:
            return [NSSortDescriptor(keyPath: \Person.name, ascending: true)]
        }
    }
}

// MARK: - Person

class Person: NSManagedObject, Fetchable {
    typealias Filter = PersonFilter
    typealias Sort = PersonSort

    @NSManaged var age: Int
    @NSManaged var name: String
    @NSManaged var isActive: Bool
}
