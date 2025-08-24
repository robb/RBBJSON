import Foundation

extension JSON: Comparable {
    static func sortKey(value: JSON) -> Int {
        switch value {
        case .object: 1
        case .array: 2
        case .number: 3
        case .string: 4
        case .bool: 5
        case .null: 6
        }
    }

    /// Compares two `RBBJSON` values against each other.
    ///
    /// Note that this is not equivalent to JavaScript's comparison of
    /// heterogenous values.
    public static func < (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case let (.object(l), .object(r)): l.count < r.count
        case let (.array(l), .array(r)): l.count < r.count
        case let (.string(l), .string(r)): l < r
        case let (.number(l), .number(r)): l < r
        case let (.bool(l), .bool(r)): (l ? 1 : 0) < (r ? 1 : 0)
        case (.null, .null): false
        default: sortKey(value: lhs) < sortKey(value: rhs)
        }
    }
}
