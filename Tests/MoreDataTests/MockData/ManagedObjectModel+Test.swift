import CoreData

extension NSManagedObjectModel {

    static func makeTestModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Person entity
        let personEntity = NSEntityDescription()
        personEntity.name = "Person"
        personEntity.managedObjectClassName = "Person"

        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = false

        let ageAttribute = NSAttributeDescription()
        ageAttribute.name = "age"
        ageAttribute.attributeType = .integer16AttributeType
        ageAttribute.isOptional = false

        personEntity.properties = [nameAttribute, ageAttribute]

        // Address entity
        let addressEntity = NSEntityDescription()
        addressEntity.name = "Address"
        addressEntity.managedObjectClassName = "Address"

        let streetAttribute = NSAttributeDescription()
        streetAttribute.name = "street"
        streetAttribute.attributeType = .stringAttributeType
        streetAttribute.isOptional = false

        let cityAttribute = NSAttributeDescription()
        cityAttribute.name = "city"
        cityAttribute.attributeType = .stringAttributeType
        cityAttribute.isOptional = false

        addressEntity.properties = [streetAttribute, cityAttribute]

        // Relationship: Person to Address (one-to-one)
        let addressRelationship = NSRelationshipDescription()
        addressRelationship.name = "address"
        addressRelationship.destinationEntity = addressEntity
        addressRelationship.minCount = 0
        addressRelationship.maxCount = 1
        addressRelationship.deleteRule = .nullifyDeleteRule

        // Relationship: Address to Person (one-to-one)
        let personRelationship = NSRelationshipDescription()
        personRelationship.name = "person"
        personRelationship.destinationEntity = personEntity
        personRelationship.minCount = 0
        personRelationship.maxCount = 1
        personRelationship.deleteRule = .nullifyDeleteRule

        // Inverse relationships
        addressRelationship.inverseRelationship = personRelationship
        personRelationship.inverseRelationship = addressRelationship

        personEntity.properties.append(addressRelationship)
        addressEntity.properties.append(personRelationship)

        model.entities = [personEntity, addressEntity]

        return model
    }
}
