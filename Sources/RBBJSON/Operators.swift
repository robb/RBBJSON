import Foundation

public func ?? (lhs: consuming JSON, rhs: @autoclosure () throws -> JSON) rethrows -> JSON {
    lhs == .null ? (try rhs()) : lhs
}

infix operator ??= : AssignmentPrecedence

public func ??= (lhs: inout JSON, rhs: @autoclosure () throws -> JSON) rethrows {
    lhs = try lhs ?? rhs()
}
