import CoreData
import XCTest
@testable import MoreData

// MARK: - TestEntityFilter

enum TestEntityFilter: Filtering {
    case nameContains(String)
    case isActive(Bool)

    var predicate: NSPredicate {
        switch self {
        case .nameContains(let name):
            return .contains(\TestEntity.name, substring: name)
        case .isActive(let isActive):
            return .is(\TestEntity.isActive, isActive)
        }
    }
}

// MARK: - TestEntitySort

enum TestEntitySort: Sorting {
    case nameAscending

    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .nameAscending:
            return [NSSortDescriptor(keyPath: \TestEntity.name, ascending: true)]
        }
    }
}

// MARK: - TestEntity

class TestEntity: NSManagedObject, Fetchable {
    typealias Filter = TestEntityFilter
    typealias Sort = TestEntitySort

    static var entityName: String {
        "TestEntity"
    }

    @NSManaged var name: String?
    @NSManaged var isActive: Bool

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

        let isActiveAttribute = NSAttributeDescription()
        isActiveAttribute.name = "isActive"
        isActiveAttribute.attributeType = .booleanAttributeType
        isActiveAttribute.isOptional = false
        isActiveAttribute.defaultValue = true

        entity.properties = [nameAttribute, isActiveAttribute]
        model.entities = [entity]
        return model
    }
}
