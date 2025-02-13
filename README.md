# More Data

[![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/iOS-15.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Platforms](https://img.shields.io/badge/macOS-12.0%2B-blue.svg)](https://developer.apple.com/macos/)
[![Platforms](https://img.shields.io/badge/tvOS-15.0%2B-blue.svg)](https://developer.apple.com/tvos/)
[![Platforms](https://img.shields.io/badge/watchOS-8.0%2B-blue.svg)](https://developer.apple.com/watchos/)
[![Platforms](https://img.shields.io/badge/visionOS-1.0%2B-blue.svg)](https://developer.apple.com/visionos/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Helpers for integrating Core Data with a modern app, using Swift enums, Combine publishers, and structured concurrency. Includes:

- **Fetchable** protocol: Adds a bunch of static helper methods to your entity classes that make data manipulation easier in a Swift app.
- **FetchableResultsPublisher**: Reactive fetching and observing of Core Data entities using a Combine publisher.
- **Filtering** protocol: Allows you to create Swift enums that simplify the creation and combination of `NSPredicate` objects for specifying filter criteria.
- **Sorting** protocol: Allows you to create Swift enums that simplify the creation of `NSSortDescriptor` objects for sorting fetched results.
- **@FetchableRequest** property wrapper: A better way to power SwiftUI views, backed by Core Data, in the modern Swift way.
- **CoreDataPersistenceController**: Pre-approved boilerplate for a full Core Data stack, providing easy setup for recommended best practices.

**More Data** is designed to streamline working with Core Data in Swift projects. Core Data is a powerful and mature framework, but is clunky and written in Objective-C, bridged to Swift. The collection of protocols and utilities here retains the power of Core Data but allows you to simplify by building a more declarative and Swift-native interface for your data layer.

## Installation

### Swift Package Manager

To integrate `MoreData` into your project using [Swift Package Manager](https://swift.org/package-manager/), add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ChrisLaganiere/MoreData.git", from: "2.0.2")
]
```

## Contents

### Fetchable

`Fetchable` allows composable, declarative fetch requests with Core Data entities.

To use it, define `Sort` and `Filter` types for your entity class, implementing the `SortProtocol` and `FilteringProtocol` described below. Then, simply conform your Core Data entity's `NSManagedObject` subclass to the `Fetchable` protocol. You will get, as a result, static helper methods to perform easy, composable, declarative fetch requests.

Making a fetch request is such a pain with vanilla Core Data:
```swift
// This is how you normally have to do it, very verbose and the predicate is not type-safe ❌
let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Person.name), "Kyle")
fetchRequest.sortDescriptors = [
    NSSortDescriptor(keyPath: \Person.name, ascending: true)
]
fetchRequest.fetchLimit = 10
let results = try moc.fetch(fetchRequest)
```

So much easier with some wrappers bridging to modern Swift using More Data:
```swift
// Same thing, much easier ✅
let results = try Person.all(
    matching: .nameContains("Kyle"),
    sortedBy: .name,
    fetchLimit: 10,
    moc: moc
)
```

#### Example Fetchable protocol implementation

```swift
import CoreData
import MoreData

class Person: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var age: Int
}

// MARK: Fetchable
extension Person: Fetchable { }

// This gets even better -- we'll set up nicer sort and filter types to replace the NSPredicate below
let kyles = try? Person.all(predicate: NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Person.name), "Kyle"), moc: moc)
```

### Filtering

The `Filtering` protocol allows you to define reusable and composable filters to replace `NSPredicate` for Core Data queries in your app code. Consider making an enum with available filtering options.

#### Example of Filtering protocol implementation

```swift
extension Person {
    typealias Filter = PersonFilter
}

enum PersonFilter: Filtering {
    case nameContains(String)
    case ageGreaterThan(Int)

    var predicate: NSPredicate {
        switch self {
        case .nameContains(let name):
            return .contains(\Person.name, substring: name) // `NSPredicate` helper included in More Data
        case .ageGreaterThan(let age):
            return .greaterThanOrEqualTo(\Person.age, value: 25) // `NSPredicate` helper included in More Data
        }
    }
}

let kylesFilter = PersonFilter.nameContains("Kyle")
let kyles = try? Person.all(matching: kylesFilter, moc: moc)
```

### Sorting

The `Sorting` protocol allows you to define Swift-friendly sort criteria to replace `NSSortDescriptor` for Core Data query results in your app code. Consider making an enum with available sort options.

#### Example of Sorting protocol implementation

```swift
extension Person {
    typealias Sort = PersonSort
}

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

`FetchableResultsPublisher` provides a Combine publisher interface on fetch results to make simple, composable, long-running Core Data query streams. This makes it easy to integrate data flows in view models, with `@MainActor` services, or with UI frameworks like TCA.

An even easier solution to power your views is provided further below provided with a SwiftUI property wrapper, but sometimes you need to integrate data flows with other components in your app. `FetchableResultsPublisher` is good for this.

#### Example of FetchableResultsPublisher usage

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
    
// Start up publisher to observe for changes matching fetch request
kylePublisher.beginFetch()

// ...later, pause publisher and stop observing
kylePublisher.endFetch()
```

### @FetchableRequest Property Wrapper

Use this if you have a simple SwiftUI view and just want to display data. If your use case is that simple, you can use managed object fetch results directly to provide data in your view builders.

`@FetchableRequest` property wrapper provides fetch results of `NSManagedObject` entities conforming to `Fetchable` protocol directly within SwiftUI views. It is similar to the Core Data property wrapper `@FetchRequest`, but provides a more declarative interface for the same goal of fetching results from the app's entity graph seamlessly within SwiftUI views.

Features
* **Declarative Fetching**: Easily fetch entities based on filter and sort criteria directly within your SwiftUI views.
* **Reactive Updates**: Automatically updates your view when the underlying Core Data changes.
* **Dynamic Querying**: Modify filter and sort criteria dynamically, and the results will update automatically.

#### Example of @FetchableRequest property wrapper usage
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

### Example App

Included in [`/Example`](./Example) is a sample app showing best practices across the data layer of an app. This one is called **More Drama**! It makes use of **Core Data** and _**More Data**_ for a common and fairly complicated use case... Displaying, filtering, sorting, and persisting items in an entity graph, with relationships. Specifically, relationships between some wild gossipers! The app UI layer of this sample app is implemented in less than 100 lines of code, showing the power and simplicity of **Core Data + More Data**.

| <img src="https://github.com/user-attachments/assets/6b23818e-dbc8-4fc5-b6e8-fd3f1ddc5b3b" width=300 /> | <img src="https://github.com/user-attachments/assets/aa570a69-bd99-4f0c-a33a-01c0c3ab9f14" width=300 /> |
| --- | --- |

### Background

[Core Data is a long-serving Apple framework](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html) reducing the amount of code you need to write for a robust, persistent entity graph.

[Core Data entities are not thread-safe](https://developer.apple.com/documentation/coredata/using_core_data_in_the_background) and should only be used in the context where they were fetched.

### License
This project is licensed under the MIT License.

### Acknowledgements

Created by Chris Laganiere with advice and lessons from greater developers.

Contributions are welcome! If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.
