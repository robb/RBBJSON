import Foundation

public extension UUID {
    init?(_ json: JSON) {
        if case let .string(value) = json {
            self.init(uuidString: value)
        } else {
            return nil
        }
    }
}

public extension JSON {
    static var uuid: JSON {
        .string(UUID().uuidString)
    }
}
