import Foundation

public func ?? (lhs: RBBJSON, rhs: RBBJSON) -> RBBJSON {
    lhs == .null ? rhs : lhs
}
