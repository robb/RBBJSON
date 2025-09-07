import Foundation

public func ?? (lhs: JSON, rhs: @autoclosure () throws -> JSON) rethrows -> JSON {
    lhs == .null ? (try rhs()) : lhs
}

infix operator ??? : NilCoalescingPrecedence

public func ??? (lhs: JSON, rhs: @autoclosure () throws -> JSON) rethrows -> JSON {
    switch lhs {
    case 0, "", .null: try rhs()
    case .number(let number) where number.isNaN: try rhs()
    default: lhs
    }
}

infix operator ??= : AssignmentPrecedence

public func ??= (lhs: inout JSON, rhs: @autoclosure () throws -> JSON) rethrows {
    lhs = try lhs ?? rhs()
}

infix operator ???= : AssignmentPrecedence

public func ???= (lhs: inout JSON, rhs: @autoclosure () throws -> JSON) rethrows {
    lhs = try lhs ??? rhs()
}
