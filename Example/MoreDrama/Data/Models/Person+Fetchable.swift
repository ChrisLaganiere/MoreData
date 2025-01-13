import CoreData
import MoreData

extension Person: Fetchable {
    public typealias Filter = PersonFilter
    public typealias Sort = PersonSort
}
