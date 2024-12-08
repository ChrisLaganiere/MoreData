import Foundation
import CoreData


extension Person {

    @NSManaged public var avatarFileName: String
    @NSManaged public var birthdate: Date
    @NSManaged public var name: String
    @NSManaged public var personID: String
    @NSManaged public var heard: NSSet/*<Statement>*/
    @NSManaged public var stated: NSSet/*<Statement>*/

}

// MARK: Generated accessors for heard
extension Person {

    @objc(addHeardObject:)
    @NSManaged public func addToHeard(_ value: Statement)

    @objc(removeHeardObject:)
    @NSManaged public func removeFromHeard(_ value: Statement)

    @objc(addHeard:)
    @NSManaged public func addToHeard(_ values: NSSet)

    @objc(removeHeard:)
    @NSManaged public func removeFromHeard(_ values: NSSet)

}

// MARK: Generated accessors for stated
extension Person {

    @objc(addStatedObject:)
    @NSManaged public func addToStated(_ value: Statement)

    @objc(removeStatedObject:)
    @NSManaged public func removeFromStated(_ value: Statement)

    @objc(addStated:)
    @NSManaged public func addToStated(_ values: NSSet)

    @objc(removeStated:)
    @NSManaged public func removeFromStated(_ values: NSSet)

}

extension Person : Identifiable {
    public var id: String {
        personID
    }
}
