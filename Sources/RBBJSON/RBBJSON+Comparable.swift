import Foundation

extension RBBJSON: Comparable {
    static func sortKey(value: RBBJSON) -> Int {
        switch value {
        case .object:
            return 1
        case .array:
            return 2
        case .number:
            return 3
        case .string:
            return 4
        case .bool:
            return 5
        case .null:
            return 6
        }
    }

    /// Compares two `RBBJSON` values against each other.
    ///
    /// Note that this is not equivalent to JavaScript's comparison of
    /// heterogenous values.
    public static func < (lhs: RBBJSON, rhs: RBBJSON) -> Bool {
        switch (lhs, rhs) {
        case (.object(let l), .object(let r)):
            return l.count < r.count
        case (.array(let l), .array(let r)):
            return l.count < r.count
        case (.string(let l), .string(let r)):
            return l < r
        case (.number(let l), .number(let r)):
            return l < r
        case (.bool(let l), .bool(let r)):
            return (l ? 1 : 0) < (r ? 1 : 0)
        case (.null, .null):
            return false
        default:
            return sortKey(value: lhs) < sortKey(value: rhs)
        }
    }
}
