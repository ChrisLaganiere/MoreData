import CoreData
import MoreData

// MARK: Core Data

@objc(Person)
public class Person: NSManagedObject { }

// MARK: More Data

extension Person: Fetchable { }
