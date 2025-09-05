import Foundation
#if canImport(CoreGraphics)
import CoreGraphics

public extension CGFloat {
    init?(_ json: JSON, lenient: Bool = false) {
        switch (json, lenient) {
        case let (.number(value), _):
            self = Self(value)
        case let (.string(string), true):
            guard let double = Double(string) else {
                return nil
            }

            self.init(double)
        default:
            return nil
        }
    }
}
#endif

public extension Double {
    init?(_ json: JSON, lenient: Bool = false) {
        switch (json, lenient) {
        case let (.number(value), _):
            self = Self(value)
        case let (.string(string), true):
            self.init(string)
        default:
            return nil
        }
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

public extension FixedWidthInteger {
    init?(_ json: JSON, lenient: Bool = false) {
        switch (json, lenient) {
        case let (.number(value), _):
            self = Self(value)
        case let (.string(string), true):
            if let value = Self(string) {
                self = value
            } else if let double = Double(json, lenient: true) {
                self.init(double)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

public extension Float {
    init?(_ json: JSON, lenient: Bool = false) {
        switch (json, lenient) {
        case let (.number(value), _):
            self = Self(value)
        case let (.string(string), true):
            self.init(string)
        default:
            return nil
        }
    }
}

public extension JSONConverter where Self == FloatConverter {
    static var float: FloatConverter { .init() }
}

public struct FloatConverter: JSONConverter {
    public func fromJSON(_ json: JSON) -> Float? {
        Float(json)
    }

    public func toJSON(_ value: Float) -> JSON {
        .number(Double(value))
    }
}
