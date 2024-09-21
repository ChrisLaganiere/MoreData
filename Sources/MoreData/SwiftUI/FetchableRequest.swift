// Copyright © 2024 Ambience Healthcare

import CoreData
import SwiftUI

/// # FetchableRequest
/// A property wrapper type that retrieves entities from a Core Data persistent
/// store, for entity types which adopt the `Fetchable` protocol for easy fetching.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@MainActor
@propertyWrapper
public struct FetchableRequest<Result>: DynamicProperty where Result: Fetchable {

    // MARK: Lifecycle

    public init(
        entity _: Result.Type,
        filter: Result.Filter?,
        sort: Result.Sort?,
        animation: Animation? = nil
    ) {
        self._filter = State(initialValue: filter)
        self._sort = State(initialValue: sort)
        self._fetchResults = FetchRequest(
            sortDescriptors: sort?.sortDescriptors ?? [],
            predicate: filter?.predicate,
            animation: animation
        )
    }

    // MARK: Public

    /// The filter criteria used to determine which entities are fetched.
    @State public var filter: Result.Filter? {
        didSet {
            updateFetchRequest()
        }
    }

    /// The sort criteria used to order the fetched entities.
    @State public var sort: Result.Sort? {
        didSet {
            updateFetchRequest()
        }
    }

    /// The fetched results that the property wrapper exposes.
    public var wrappedValue: FetchedResults<Result> {
        fetchResults
    }

    // MARK: Private

    // MARK: Private Properties

    /// The fetched results that the property wrapper will expose.
    @FetchRequest private var fetchResults: FetchedResults<Result>

    // MARK: Private Methods

    private func updateFetchRequest() {
        fetchResults.nsPredicate = filter?.predicate
        fetchResults.nsSortDescriptors = sort?.sortDescriptors ?? []
    }
}
