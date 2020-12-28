import CoreGraphics
import Foundation

public extension CGFloat {
    init?(_ json: RBBJSON, lenient: Bool = false) {
        switch (json, lenient) {
        case (.number(let value), _):
            self = Self(value)
        case (.string(let string), true):
            guard let double = Double(string) else {
                return nil
            }

            self.init(double)
        default:
            return nil
        }
    }
}

public extension Double {
    init?(_ json: RBBJSON, lenient: Bool = false) {
        switch (json, lenient) {
        case (.number(let value), _):
            self = Self(value)
        case (.string(let string), true):
            self.init(string)
        default:
            return nil
        }
    }
}

public extension FixedWidthInteger {
    init?(_ json: RBBJSON, lenient: Bool = false) {
        switch (json, lenient) {
        case (.number(let value), _):
            self = Self(value)
        case (.string(let string), true):
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
    init?(_ json: RBBJSON, lenient: Bool = false) {
        switch (json, lenient) {
        case (.number(let value), _):
            self = Self(value)
        case (.string(let string), true):
            self.init(string)
        default:
            return nil
        }
    }
}
