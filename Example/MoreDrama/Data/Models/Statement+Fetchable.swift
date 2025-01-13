import CoreData
import MoreData

extension Statement: Fetchable {
    public typealias Filter = StatementFilter
    public typealias Sort = StatementSort
}
