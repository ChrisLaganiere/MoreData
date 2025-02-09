# More Data

[![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/iOS-15.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Platforms](https://img.shields.io/badge/macOS-12.0%2B-blue.svg)](https://developer.apple.com/macos/)
[![Platforms](https://img.shields.io/badge/tvOS-15.0%2B-blue.svg)](https://developer.apple.com/tvos/)
[![Platforms](https://img.shields.io/badge/watchOS-8.0%2B-blue.svg)](https://developer.apple.com/watchos/)
[![Platforms](https://img.shields.io/badge/visionOS-1.0%2B-blue.svg)](https://developer.apple.com/visionos/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Helpers for integrating Core Data with a modern app, using Swift enums, Combine publishers, and structured concurrency.

**More Data** is designed to streamline working with Core Data in Swift projects. Core Data is a powerful and mature framework, but is clunky and not Swift-native. This collection of protocols and utilities simplify fetching, filtering, and observing Core Data entities using a more reactive and Swift-friendly approach.

## Features

- **FetchableResultsPublisher**: Reactive fetching and observing of Core Data entities using Combine.
- **Filtering**: Swift enums simplify the creation and combination of `NSPredicate` objects used to specify filter criteria.
- **Sorting**: Swift enums simplify the creation and combination of `NSSortDescriptor` objects for sorting query results.
- **@FetchableRequest Property Wrapper**: A better way to power SwiftUI views, backed by Core Data, in the modern Swift way.
- **CoreDataPersistenceController**: Wrapper for boilerplate Core Data setup, providing easy initialization for recommended best practices.

## Installation

### Swift Package Manager

To integrate `MoreData` into your project using [Swift Package Manager](https://swift.org/package-manager/), add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ChrisLaganiere/MoreData.git", from: "2.0.2")
]
```

## Usage

#### Example App

Included in [`/Example`](./Example) is a sample app showing best practices across the data layer of an app. This one is called **More Drama**! It makes use of **Core Data** and _**More Data**_ for a common and fairly complicated use case... Displaying, filtering, sorting, and persisting items in an entity graph, with relationships. Specifically, relationships between some wild gossipers! The app UI layer of this sample app is implemented in less than 100 lines of code, showing the power and simplicity of **Core Data + More Data**.

| <img src="https://github.com/user-attachments/assets/6b23818e-dbc8-4fc5-b6e8-fd3f1ddc5b3b" width=300 /> | <img src="https://github.com/user-attachments/assets/aa570a69-bd99-4f0c-a33a-01c0c3ab9f14" width=300 /> |
| --- | --- |

The More Data package contains several components:

### Fetchable Protocol

`Fetchable` allows composable, declarative fetch requests with Core Data entities.

To use it, define `Sort` and `Filter` types for your entity class, implementing the `SortProtocol` and `FilteringProtocol` described below. Then, simply conform your Core Data entity's `NSManagedObject` subclasses to `Fetchable` protocol. You can then use all the provided helpers methods to perform easy, composable, declarative fetch requests.

Making a predicate is such a pain with vanilla Core Data:
```swift
// Performing a search of `Person` records
let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Person.name), "Kyle")
fetchRequest.predicate = predicate
let sortDescriptor = NSSortDescriptor(keyPath: \Person.name, ascending: true)
fetchRequest.sortDescriptors = [sortDescriptor]
let results = try moc.fetch(fetchRequest)
```

So much easier with some wrappers bridging to modern Swift using More Data:
```swift
let results = try Person.all(matching: .nameContains("Kyle"), sortedBy: .name, moc: moc)
```

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

The `Filtering` protocol allows you to define reusable and composable filters for Core Data queries. Consider making an enum with available filtering options.

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

The `Sorting` protocol allows you to define Swift-friendly sort criteria for Core Data fetch results. Consider making an enum with available sort options.

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

A solution is provided further below provided for powering SwiftUI views using a simple property wrapper, but sometimes you need to integrate data flows with other components in your app. A Combine publisher is included which wraps Core Data's  

`FetchableResultsPublisher` provides a Combine publisher interface to make simple, composable, long-running fetched results streams for Core Data entities, making it easy to integrate with view models, with `@MainActor` services, or with UI frameworks like TCA.

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

// You may want to store cancellable handles to publishers as an instance property in whatever class/struct you are building.
var cancellables: Set<AnyCancellable> = []

kylePublisher.fetchedObjectsPublisher
    .sink { fetchedObjects in
        // Update your UI, or do anything you want, on the main thread, with the fetched objects.
        // This block continues to get called with any changes when any items matching the fetch
        // request are created, updated, or deleted in the managed object context.
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
