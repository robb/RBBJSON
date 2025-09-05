import Foundation

public extension Array where Element == JSON {
    init?(_ json: JSON) {
        switch json {
        case let .array(array): self = array
        default: return nil
        }
    }
}

public extension JSONConverter where Self == ArrayConverter {
    static var array: ArrayConverter { .init() }
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

public extension JSONConverter {
    static func array<T: JSONConverter>(of converter: T) -> TypedArrayConverter<T> where Self == TypedArrayConverter<T> {
        TypedArrayConverter(elementConverter: converter)
    }
}

public struct TypedArrayConverter<Element: JSONConverter>: JSONConverter {
    public typealias Value = [Element.Value?]

    public var elementConverter: Element

    public func fromJSON(_ json: JSON) -> Value? {
        ArrayConverter().fromJSON(json)?.map { element in
            elementConverter.fromJSON(element)
        }
    }

    public func toJSON(_ value: Value) -> JSON {
        ArrayConverter().toJSON(value.map { element in
            element.map(elementConverter.toJSON) ?? .null
        })
    }
}
