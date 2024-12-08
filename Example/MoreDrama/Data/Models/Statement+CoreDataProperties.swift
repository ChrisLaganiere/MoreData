import Foundation
import CoreData


extension Statement {

    @NSManaged public var statementID: String
    @NSManaged public var content: String
    @NSManaged public var time: Date
    @NSManaged public var by: Person
    @NSManaged public var to: NSSet/*<Person>*/

}

// MARK: Generated accessors for to
extension Statement {

    @objc(addToObject:)
    @NSManaged public func addToTo(_ value: Person)

    @objc(removeToObject:)
    @NSManaged public func removeFromTo(_ value: Person)

    @objc(addTo:)
    @NSManaged public func addToTo(_ values: NSSet)

    @objc(removeTo:)
    @NSManaged public func removeFromTo(_ values: NSSet)

}

extension Statement : Identifiable {
    public var id: String {
        statementID
    }
}
