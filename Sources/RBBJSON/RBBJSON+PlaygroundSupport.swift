import Foundation

extension RBBJSON: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        switch self {
        case .object(let object):
            return object.mapValues(\.playgroundDescription)
        case .array(let values):
            return values.map(\.playgroundDescription)
        case .string(let value):
            return value
        case .number(let value):
            return value
        case .bool(let value):
            return value
        case .null:
            return Optional<String>.none as Any
        }
    }
}
