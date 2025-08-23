import Foundation

public extension UUID {
    init?(_ json: RBBJSON) {
        if case let .string(value) = json {
            self.init(uuidString: value)
        } else {
            return nil
        }
    }
}

public extension RBBJSON {
    static var uuid: RBBJSON {
        .string(UUID().uuidString)
    }
}
