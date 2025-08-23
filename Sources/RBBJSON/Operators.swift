import Foundation

public func ?? (lhs: consuming RBBJSON, rhs: @autoclosure () throws -> RBBJSON) rethrows -> RBBJSON {
    lhs == .null ? (try rhs()) : lhs
}
