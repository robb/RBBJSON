import Foundation

public func ?? (lhs: consuming JSON, rhs: @autoclosure () throws -> JSON) rethrows -> JSON {
    lhs == .null ? (try rhs()) : lhs
}
