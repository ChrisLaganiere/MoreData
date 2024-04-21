import CoreData
import MoreData

/// Sort descriptors which specify how to sort fetched results
public enum StatementSort: Sorting {

    /// Time when statement was made, newest first
    case newest
    /// Time when statement was made, oldest first
    case oldest

    public var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .newest:
            return [
                NSSortDescriptor(keyPath: \Statement.time, ascending: false)
            ]
        case .oldest:
            return [
                NSSortDescriptor(keyPath: \Statement.time, ascending: true)
            ]
        }
    }
}
