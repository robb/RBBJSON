import Foundation

public extension Bool {
    init?(_ json: JSON, lenient: Bool = false) {
        switch (json, lenient) {
        case (.bool(let value), _): self = value
        case (.string("true"), true): self = true
        case (.string("false"), true): self = false
        case (.number(let value), true): self = value != 0
        default:
            return nil
        }
    }
}

public extension JSONConverter where Self == BoolConverter {
    static var bool: BoolConverter { .init() }
}

public struct BoolConverter: JSONConverter {
    public func fromJSON(_ json: JSON) -> Bool? {
        Bool(json)
    }

    public func toJSON(_ value: Bool) -> JSON {
        .bool(value)
    }
}
