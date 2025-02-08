import CoreData
import MoreData

@objc(Statement)
public class Statement: NSManagedObject { }

extension Statement: Fetchable {
    public typealias Filter = StatementFilter
    public typealias Sort = StatementSort
}
