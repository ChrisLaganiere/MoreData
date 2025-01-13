import CoreData

// MARK: - Address

class Address: NSManagedObject {

    @NSManaged var street: String
    @NSManaged var city: String

    // MARK: Relationships

    @NSManaged var person: Person?
}
