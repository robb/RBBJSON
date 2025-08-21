import Foundation

fileprivate struct JSONCodingKeys: CodingKey {
    internal var stringValue: String

    internal init?(stringValue: String) {
        self.stringValue = stringValue
    }

    internal var intValue: Int?

    internal init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

@dynamicMemberLookup
public enum RBBJSON: Hashable, Codable, Sendable {
    case object([String: RBBJSON])
    case array([RBBJSON])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    public init(from decoder: Decoder) throws {
        self = if let container = try? decoder.container(keyedBy: JSONCodingKeys.self) {
            try RBBJSON(container: container)
        } else if var container = try? decoder.unkeyedContainer() {
            try RBBJSON(container: &container)
        } else if let container = try? decoder.singleValueContainer() {
            if let bool = try? container.decode(Bool.self) {
                .bool(bool)
            } else if let number = try? container.decode(Double.self) {
                .number(number)
            } else if let string = try? container.decode(String.self) {
                .string(string)
            } else if container.decodeNil() {
                .null
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: ""))
            }
        }
        else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: ""))
        }
    }

    private init(container: KeyedDecodingContainer<JSONCodingKeys>) throws {
        let values = try container.allKeys.map { codingKey -> RBBJSON in
            try container.decode(RBBJSON.self, forKey: codingKey)
        }

        let zipped = zip(container.allKeys.map(\.stringValue), values)

        self = .object(Dictionary(zipped) { a, _ in a })
    }

    private init(container: inout UnkeyedDecodingContainer) throws {
        var values: [RBBJSON] = []

        while !container.isAtEnd {
            values.append(try container.decode(RBBJSON.self))
        }

        self = .array(values)
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .object(object):
            var container = encoder.container(keyedBy: JSONCodingKeys.self)

            for (key, value) in object {
                let codingKey = JSONCodingKeys(stringValue: key)!

                try container.encode(value, forKey: codingKey)
            }
        case let .array(array):
            var container = encoder.unkeyedContainer()

            for value in array {
                try container.encode(value)
            }
        case let .string(string):
            var container = encoder.singleValueContainer()

            try container.encode(string)
        case let .number(number):
            var container = encoder.singleValueContainer()

            try container.encode(number)
        case let .bool(bool):
            var container = encoder.singleValueContainer()

            try container.encode(bool)
        case .null:
            var container = encoder.singleValueContainer()

            try container.encodeNil()
        }
    }

    public subscript(index: Int) -> RBBJSON {
        guard case let .array(array) = self else { return .null }

        return array[wrapping: index] ?? .null
    }

    public subscript(key: String) -> RBBJSON {
        guard case let .object(object) = self else { return .null }

        return object[key] ?? .null
    }

    public subscript(dynamicMember member: String) -> RBBJSON {
        self[member]
    }

    public static func keys(_ json: RBBJSON) -> [String] {
        switch json {
        case let .object(object): Array(object.keys).sortedIfDebug
        default: []
        }
    }

    public static func values(_ json: RBBJSON) -> [RBBJSON] {
        switch json {
        case let .object(object): Array(object.values).sortedIfDebug
        case let .array(array): array
        default: []
        }
    }

    /// The JSON value as a sequence.
    public var ƒ: some Sequence<RBBJSON> {
        switch self {
        case let .object(object): Array(object.values).sortedIfDebug
        case let .array(array): array
        case .null: Array<RBBJSON>()
        default: [self]
        }
    }
}

extension RBBJSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .object(object): object.debugDescription
        case let .array(array): array.debugDescription
        case let .string(string): string.debugDescription
        case let .number(number): number.debugDescription
        case let .bool(bool): bool ? "true" : "false"
        case .null: "null"
        }
    }
}
