import CoreData
import MoreData

extension Statement: Fetchable {
    public typealias Filter = StatementFilter
    public typealias Sort = StatementSort

    public static var entityName: String {
        "Statement"
    }
}
