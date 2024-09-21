// Copyright © 2024 Ambience Healthcare

import Foundation

extension NSPredicate {
    public static func matching<T: CVarArg>(_ keyPath: KeyPath<some Any, T>, value: T) -> NSPredicate {
        NSPredicate(format: "%K == %@", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func matching(_ keyPath: KeyPath<some Any, Int>, value: Int) -> NSPredicate {
        NSPredicate(format: "%K == %@", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func greaterThanOrEqualTo(_ keyPath: KeyPath<some Any, Int>, value: Int) -> NSPredicate {
        NSPredicate(format: "%K >= %@", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func lessThanOrEqualTo(_ keyPath: KeyPath<some Any, Int>, value: Int) -> NSPredicate {
        NSPredicate(format: "%K <= %@", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func greaterThan(_ keyPath: KeyPath<some Any, Int>, value: Int) -> NSPredicate {
        NSPredicate(format: "%K > %@", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func lessThan(_ keyPath: KeyPath<some Any, Int>, value: Int) -> NSPredicate {
        NSPredicate(format: "%K < %@", NSExpression(forKeyPath: keyPath).keyPath, value)
    }

    public static func `true`(_ keyPath: KeyPath<some Any, Bool>) -> NSPredicate {
        NSPredicate(format: "%K == YES", NSExpression(forKeyPath: keyPath).keyPath)
    }

    public static func `false`(_ keyPath: KeyPath<some Any, Bool>) -> NSPredicate {
        NSPredicate(format: "%K == NO", NSExpression(forKeyPath: keyPath).keyPath)
    }
}
