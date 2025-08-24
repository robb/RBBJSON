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
public enum JSON: Hashable, Codable, Sendable {
    case object([String: JSON])
    case array([JSON])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    public init(from decoder: Decoder) throws {
        self = if let container = try? decoder.container(keyedBy: JSONCodingKeys.self) {
            try JSON(container: container)
        } else if var container = try? decoder.unkeyedContainer() {
            try JSON(container: &container)
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
        let values = try container.allKeys.map { codingKey -> JSON in
            try container.decode(JSON.self, forKey: codingKey)
        }

        let zipped = zip(container.allKeys.map(\.stringValue), values)

        self = .object(Dictionary(zipped) { a, _ in a })
    }

    private init(container: inout UnkeyedDecodingContainer) throws {
        var values: [JSON] = []

        while !container.isAtEnd {
            values.append(try container.decode(JSON.self))
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

    public subscript(index: Int) -> JSON {
        guard case let .array(array) = self else { return .null }

        return array[wrapping: index] ?? .null
    }

    public subscript(key: String) -> JSON {
        get {
            guard case let .object(object) = self else { return .null }

            return object[key] ?? .null
        }
        set {
            switch self {
            case var .object(object):
                object[key] = newValue
                self = .object(object)
            default:
                print("Attempted to assign \(newValue) to property \(key) on \(self).")
            }
        }
    }

    public subscript(dynamicMember member: String) -> JSON {
        get {
            self[member]
        }
        set {
            switch self {
            case var .object(object):
                object[member] = newValue
                self = .object(object)
            default:
                print("Attempted to assign \(newValue) to property \(member) on \(self).")
            }
        }
    }

    public static func keys(_ json: JSON) -> [String] {
        switch json {
        case let .object(object): Array(object.keys).sortedIfDebug
        default: []
        }
    }

    public static func values(_ json: JSON) -> [JSON] {
        switch json {
        case let .object(object): Array(object.values).sortedIfDebug
        case let .array(array): array
        default: []
        }
    }
}

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        debugDescription(identationLevel: 0)
    }

    func debugDescription(identationLevel l: Int) -> String {
        let padding = String(repeating: " ", count: 2 * l)
        let nested = String(repeating: " ", count: 2 * (l + 1))

        switch self {
        case let .object(object):
            var result = "{\n"
            for (key, value) in object {
                result += nested
                result += "\"\(key)\": "
                result += value.debugDescription(identationLevel: l + 1)
                result += ",\n"
            }
            result += padding
            result += "}"
            return result
        case let .array(array):
            var result = "[\n"
            for element in array {
                result += nested
                result += element.debugDescription(identationLevel: l + 1)
                result += ",\n"
            }
            result += padding
            result += "]"
            return result
        case let .string(string): return "\"\(string)\""
        case let .number(number): return number.debugDescription
        case let .bool(bool): return bool ? "true" : "false"
        case .null: return "null"
        }
    }
}
