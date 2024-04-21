import CoreData
@testable import MoreData
import XCTest

enum TestEntityFilter: Filtering {
    case nameContains(String)
    case ageGreaterThan(Int)
    case isActive(Bool)

    var predicate: NSPredicate? {
        switch self {
        case .nameContains(let name):
            return NSPredicate(format: "name CONTAINS[cd] %@", name)
        case .ageGreaterThan(let age):
            return NSPredicate(format: "age > %d", age)
        case .isActive(let isActive):
            return NSPredicate(format: "isActive == %@", NSNumber(value: isActive))
        }
    }
}

enum TestEntitySort: Sorting {
    case nameAscending

    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .nameAscending:
            return [NSSortDescriptor(key: "name", ascending: true)]
        }
    }
}

// MARK: - TestEntity
class TestEntity: NSManagedObject, Fetchable {
    @NSManaged var name: String?

    static var entityName: String { "TestEntity" }

    typealias Filter = TestEntityFilter
    typealias Sort = TestEntitySort
}

extension NSManagedObjectModel {
    static func makeTestEntityModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "TestEntity"
        entity.managedObjectClassName = NSStringFromClass(TestEntity.self)

        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = true

        entity.properties = [nameAttribute]
        model.entities = [entity]
        return model
    }
}
