import Foundation

public protocol JSONConverter {
    associatedtype Value

    func fromJSON(_ json: JSON) -> Value?

    func toJSON(_ value: Value) -> JSON
}
