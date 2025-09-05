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
    public typealias Element = JSON

    public func makeIterator() -> some IteratorProtocol<JSON> {
        switch json {
        case let .object(object): AnyIterator(object.values.makeIterator())
        case let .array(array): AnyIterator(array.makeIterator())
        default: AnyIterator(EmptyCollection<JSON>.Iterator())
        }
    }
}

public extension JSON {
    var ƒ: JSON.Wrapper {
        JSON.Wrapper(self)
    }
}
