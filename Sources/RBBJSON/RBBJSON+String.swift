import Foundation

public extension String {
    init?(_ json: RBBJSON) {
        if case .string(let value) = json {
            self = value
        } else {
            return nil
        }
    }
}
