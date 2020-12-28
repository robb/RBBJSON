import Foundation

public extension Bool {
    init?(_ json: RBBJSON, lenient: Bool = false) {
        switch (json, lenient) {
        case (.bool(let value), _):
            self = value
        case (.string("true"), true):
            self = true
        case (.string("false"), true):
            self = false
        case (.number(let value), true):
            self = value != 0
        default:
            return nil
        }
    }
}
