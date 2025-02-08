import CoreData
import MoreData

@objc(Person)
public class Person: NSManagedObject { }

extension Person: Fetchable {
    public typealias Filter = PersonFilter
    public typealias Sort = PersonSort
}
