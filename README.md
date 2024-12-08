# MoreData

[![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/iOS-15.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Platforms](https://img.shields.io/badge/macOS-12.0%2B-blue.svg)](https://developer.apple.com/macos/)
[![Platforms](https://img.shields.io/badge/tvOS-15.0%2B-blue.svg)](https://developer.apple.com/tvos/)
[![Platforms](https://img.shields.io/badge/watchOS-8.0%2B-blue.svg)](https://developer.apple.com/watchos/)
[![Platforms](https://img.shields.io/badge/visionOS-1.0%2B-blue.svg)](https://developer.apple.com/visionos/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Helpers for integrating Core Data with a modern app, using Swift enums, Combine publishers, and structured concurrency.

**MoreData** is designed to streamline working with Core Data in Swift projects. Core Data is a powerful and mature framework, but is clunky and not Swift-native. This collection of protocols and utilities simplify fetching, filtering, and observing Core Data entities using a more reactive and Swift-friendly approach.

## Features

- **Filtering**: Simplify the creation and combination of `NSPredicate` objects used to specify filter criteria.
- **Sorting**: Simplify the creation and combination of `NSSortDescriptor` objects for sorting query results.
- **@FetchableRequest Property Wrapper**: A better way to power SwiftUI views backed by Core Data.
- **FetchableResultsPublisher**: Reactive fetching and observing of Core Data entities using Combine.
- **CoreDataPersistenceController**: Wrapper for boilerplate Core Data setup, providing easy initialization for common patterns.

## Installation

### Swift Package Manager

To integrate `MoreData` into your project using [Swift Package Manager](https://swift.org/package-manager/), add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ChrisLaganiere/MoreData.git", from: "2.0.2")
]
```

## Usage

### Fetchable Protocol

The `Fetchable` protocol simplifies the process of fetching Core Data entities. Conform your NSManagedObject subclasses to Fetchable and use the provided helper methods to perform fetches.

#### Example

```swift
import CoreData
import MoreData

class Person: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var age: Int

    static var entityName: String {
        return "Person"
    }
}

// MARK: Fetchable
extension Person: Fetchable {
    typealias Filter = PersonFilter
    typealias Sort = PersonSort

    static var entityName: String {
        "Person"
    }
}

let moc: NSManagedObjectContext = // your managed object context
let kyles = try? Person.all(predicate: NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Person.name), "Kyle"), moc: moc)
```

### Filtering Protocol

The `Filtering` protocol allows you to define reusable and composable filters for Core Data queries.

#### Example

```swift
enum PersonFilter: Filtering {
    case nameContains(String)
    case ageGreaterThan(Int)

    var predicate: NSPredicate {
        switch self {
        case .nameContains(let name):
            return .contains(\Person.name, substring: name)
        case .ageGreaterThan(let age):
            return .greaterThanOrEqualTo(\Person.age, value: 25)
        }
    }
}

let kylesFilter = PersonFilter.nameContains("Kyle")
let kyles = try? Person.all(matching: kylesFilter, moc: moc)
```

### Sorting Protocol

The `Sorting` protocol allows you to define Swift-friendly sort criteria for Core Data fetch results.

#### Example

```swift
enum PersonSort: Sorting {
    /// Sort alphabetically, A-Z
    case nameAscending(Bool)

    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .nameAscending:
            return [NSSortDescriptor(keyPath: \Person.name, ascending: true)]
        }
    }
}

let kyles = try? Person.all(matching: .nameContains("Kyle"), sortedBy: .nameAscending, moc: moc)
```

### FetchableResultsPublisher

The `FetchableResultsPublisher` class provides a Combine-based interface to fetch and observe Core Data entities, making it easy to integrate with SwiftUI or other reactive UI frameworks.

#### Example

```swift
import Combine
import CoreData
import MoreData

let kylePublisher = FetchableResultsPublisher<Person>(
    filter: .nameContains("Kyle"),
    sort: .nameAscending,
    moc: moc
)

kylePublisher.fetchedObjectsPublisher
    .sink { fetchedObjects in
        // Update your UI with the fetched objects
    }
    .store(in: &cancellables)
```

### @FetchableRequest Property Wrapper

The `@FetchableRequest` property wrapper simplifies the process of retrieving and observing `NSManagedObject` entities that conform to the `Fetchable` protocol within SwiftUI views. It provides a declarative interface for fetching Core Data entities while integrating seamlessly with SwiftUI's state-driven UI updates.

Features
* **Declarative Fetching**: Easily fetch entities based on filter and sort criteria directly within your SwiftUI views.
* **Reactive Updates**: Automatically updates your view when the underlying Core Data changes.
* **Dynamic Querying**: Modify filter and sort criteria dynamically, and the results will update automatically.

#### Usage
To use `@FetchableRequest`, simply declare it in your SwiftUI view, specifying the entity type, filter, and sort criteria. The fetched results will be automatically available to your view.

```swift
import SwiftUI
import MoreData

struct PersonListView: View {

    @FetchableRequest(
        entity: Person.self,
        filter: .none,
        sort: .nameAscending
    ) var people: FetchedResults<Person>

    @State private var showKylesOnly = false

    var body: some View {
        VStack {
            Toggle("Show Kyles Only", isOn: $showKylesOnly)
                .padding()

            List(people) { person in
                VStack(alignment: .leading) {
                    Text(person.name ?? "Unknown Name")
                    Text("Age: \(person.age)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(showKylesOnly ? "Kyles" : "All People")
        }
        .onChange(of: showKylesOnly) { newValue in
            if newValue {
                _people.filter = .nameContains("Kyle")
            } else {
                _people.filter = .none
            }
        }
    }
}
```

In this example, the list dynamically updates based on the toggle state, switching between showing all people or only people named Kyle.

### Background

[Core Data is a long-serving Apple framework](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html) reducing the amount of code you need to write for a robust, persistent entity graph.

[Core Data entities are not thread-safe](https://developer.apple.com/documentation/coredata/using_core_data_in_the_background) and should only be used in the context where they were fetched.

### License
This project is licensed under the MIT License.

### Acknowledgements

Written by: Chris L 🫎

Contributions are welcome! If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.
