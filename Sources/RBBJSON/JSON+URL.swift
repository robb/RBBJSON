import Foundation

public extension URL {
    init?(_ json: JSON) {
        if case let .string(value) = json {
            self.init(string: value)
        } else {
            return nil
        }
    }
}
