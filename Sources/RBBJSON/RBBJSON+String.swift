import Foundation

public extension String {
    init?(_ json: RBBJSON) {
        if case let .string(value) = json {
            self = value
        } else {
            return nil
        }
    }
}
