import Foundation

public extension String {
    init?(_ json: JSON) {
        if case let .string(value) = json {
            self = value
        } else {
            return nil
        }
    }
}

public extension JSONConverter where Self == StringConverter {
    static var string: StringConverter { .init() }
}

public struct StringConverter: JSONConverter {
    public func fromJSON(_ json: JSON) -> String? {
        String(json)
    }

    public func toJSON(_ value: String) -> JSON {
        .string(value)
    }
}
