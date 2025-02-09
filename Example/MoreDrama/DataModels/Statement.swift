import CoreData
import MoreData

// MARK: Core Data

@objc(Statement)
public class Statement: NSManagedObject { }

// MARK: More Data

extension Statement: Fetchable { }
