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
public enum RBBJSON: Hashable, Codable {
    case object([String: RBBJSON])
    case array([RBBJSON])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: JSONCodingKeys.self) {
            self = try RBBJSON(container: container)
        } else if var container = try? decoder.unkeyedContainer() {
            self = try RBBJSON(container: &container)
        } else if let container = try? decoder.singleValueContainer() {
            if let bool = try? container.decode(Bool.self) {
                self = .bool(bool)
            } else if let number = try? container.decode(Double.self) {
                self = .number(number)
            } else if let string = try? container.decode(String.self) {
                self = .string(string)
            } else if container.decodeNil() {
                self = .null
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
        case .object(let object):
            var container = encoder.container(keyedBy: JSONCodingKeys.self)

            for (key, value) in object {
                let codingKey = JSONCodingKeys(stringValue: key)!

                try container.encode(value, forKey: codingKey)
            }
        case .array(let array):
            var container = encoder.unkeyedContainer()

            for value in array {
                try container.encode(value)
            }
        case .string(let string):
            var container = encoder.singleValueContainer()

            try container.encode(string)
        case .number(let number):
            var container = encoder.singleValueContainer()

            try container.encode(number)
        case .bool(let bool):
            var container = encoder.singleValueContainer()

            try container.encode(bool)
        case .null:
            var container = encoder.singleValueContainer()

            try container.encodeNil()
        }
    }

    public subscript(index: Int) -> RBBJSON {
        guard case .array(let array) = self else { return .null }

        return array[wrapping: index] ?? .null
    }

    public subscript(key: String) -> RBBJSON {
        guard case .object(let object) = self else { return .null }

        return object[key] ?? .null
    }

    public subscript(dynamicMember member: String) -> RBBJSON {
        self[member]
    }

    public static func keys(_ json: RBBJSON) -> [String] {
        switch json {
        case .object(let object):
            return Array(object.keys).sortedIfDebug()
        default:
            return []
        }
    }

    public static func values(_ json: RBBJSON) -> [RBBJSON] {
        switch json {
        case .object(let object):
            return Array(object.values).sortedIfDebug()
        case .array(let array):
            return array.sortedIfDebug()
        default:
            return []
        }
    }
}

internal extension Array where Element: Comparable {
    #if DEBUG
    func sortedIfDebug() -> [Element] {
        sorted()
    }
    #else
    func sortedIfDebug() -> [Element] {
        self
    }
    #endif
}


extension RBBJSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .object(let object):
            return object.debugDescription
        case .array(let array):
            return array.debugDescription
        case .string(let string):
            return string.debugDescription
        case .number(let number):
            return number.debugDescription
        case .bool(let bool):
            return bool ? "true" : "false"
        case .null:
            return "null"
        }
    }
}
