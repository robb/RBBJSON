import Foundation

extension JSON {
    public struct Wrapper {
        var json: JSON

        var keyPath: WritableKeyPath<JSON, JSON> = \.self

        var value: JSON {
            get { json[keyPath: keyPath] }
            set { json[keyPath: keyPath] = newValue }
        }

        public init(_ json: JSON) {
            self.json = json
        }
    }
}

extension JSON.Wrapper {
    public func flatMap<T: JSONConverter>(_ converter: T, transform: (T.Value) throws -> JSON) rethrows -> JSON {
        if let transformed = converter.fromJSON(json) {
            try transform(transformed)
        } else {
            json
        }
    }

    public func map<T: JSONConverter>(_ converter: T, transform: (T.Value) throws -> T.Value) rethrows -> JSON {
        if let transformed = converter.fromJSON(json) {
            try converter.toJSON(transform(transformed))
        } else {
            json
        }
    }

    public func modify<T: JSONConverter>(_ keyPath: WritableKeyPath<JSON, JSON>, as converter: T, transform: (T.Value) throws -> T.Value) rethrows -> JSON {
        var result = json
        result[keyPath: keyPath] = try JSON.Wrapper(result[keyPath: keyPath]).map(converter, transform: transform)
        return result
    }
}

extension JSON.Wrapper: Sequence {
    public func makeIterator() -> some IteratorProtocol {
        switch json {
        case let .object(object): AnyIterator(object.values.makeIterator())
        case let .array(array): AnyIterator(array.makeIterator())
        case .null: AnyIterator(EmptyCollection<JSON>.Iterator())
        default: AnyIterator(CollectionOfOne(json).makeIterator())
        }
    }
}

public protocol JSONConverter {
    associatedtype Value

    func fromJSON(_ json: JSON) -> Value?

    func toJSON(_ value: Value) -> JSON
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

public extension JSONConverter where Self == DoubleConverter {
    static var double: DoubleConverter { .init() }
}

public struct DoubleConverter: JSONConverter {
    public func fromJSON(_ json: JSON) -> Double? {
        Double(json)
    }

    public func toJSON(_ value: Double) -> JSON {
        .number(value)
    }
}

public struct ArrayConverter: JSONConverter {
    public func fromJSON(_ json: JSON) -> [JSON]? {
        switch json {
        case .array(let array): array
        default: nil
        }
    }

    public func toJSON(_ value: [JSON]) -> JSON {
        .array(value)
    }
}

public extension JSON {
    var ƒ: JSON.Wrapper {
        JSON.Wrapper(self)
    }
}
