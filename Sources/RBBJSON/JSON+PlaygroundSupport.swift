import Foundation

extension JSON: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        switch self {
        case let .object(object): object.mapValues(\.playgroundDescription)
        case let .array(values): values.map(\.playgroundDescription)
        case let .string(value): value
        case let .number(value): value
        case let .bool(value): value
        case .null: Optional<String>.none as Any
        }
    }
}
