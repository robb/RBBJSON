import Foundation

public extension URL {
    init?(_ json: RBBJSON) {
        if case let .string(value) = json {
            self.init(string: value)
        } else {
            return nil
        }
    }
}
