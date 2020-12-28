import Foundation

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public extension Date {
    enum JSONDateStringDecodingStrategy: Hashable {
        fileprivate static let isoParser = ISO8601DateFormatter()

        case iso8601
        case formatted(DateFormatter)
    }

    enum JSONDateNumberDecodingStrategy {
        case secondsSince1970
        case millisecondsSince1970
    }

    init?(_ json: RBBJSON, stringDecodingStrategoy: JSONDateStringDecodingStrategy = .iso8601, numberDecodingStrategoy: JSONDateNumberDecodingStrategy = .secondsSince1970) {
        switch (json, stringDecodingStrategoy, numberDecodingStrategoy) {
        case let (.number(value), _, .secondsSince1970):
            self = Date(timeIntervalSince1970: value)
        case let (.number(value), _, .millisecondsSince1970):
            self = Date(timeIntervalSince1970: value / 1000)
        case let (.string(value), .iso8601, _):
            if let date = JSONDateStringDecodingStrategy.isoParser.date(from: value) {
                self = date
            } else {
                return nil
            }
        case let (.string(value), .formatted(formatter), _):
            if let date = formatter.date(from: value) {
                self = date
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
