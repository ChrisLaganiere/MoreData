import CoreData

extension NSManagedObjectModel {

    static func makeTestModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Person entity
        let personEntity = NSEntityDescription()
        personEntity.name = "Person"
        personEntity.managedObjectClassName = NSStringFromClass(Person.self)

        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = false

        let ageAttribute = NSAttributeDescription()
        ageAttribute.name = "age"
        ageAttribute.attributeType = .integer64AttributeType
        ageAttribute.defaultValue = 0
        ageAttribute.isOptional = false

        let isActiveAttribute = NSAttributeDescription()
        isActiveAttribute.name = "isActive"
        isActiveAttribute.attributeType = .booleanAttributeType
        isActiveAttribute.isOptional = false
        isActiveAttribute.defaultValue = true

        personEntity.properties = [ageAttribute, isActiveAttribute, nameAttribute]

        model.entities = [personEntity]

        return model
    }
}
