// Copyright © 2024 Ambience Healthcare

import CoreData

/// # Sorting
/// Protocol for Core Data sort descriptors which specify how to sort fetched results.
public protocol Sorting: Equatable {
    var sortDescriptors: [NSSortDescriptor] { get }
}
