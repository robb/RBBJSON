import Foundation

public extension URL {
    init?(_ json: JSON) {
        if case let .string(value) = json {
            self.init(string: value)
        } else {
            return nil
        }
    }
}

public extension JSON {
    static func url(_ url: URL) -> JSON {
        .string(url.absoluteString)
    }

    static func url(_ string: String) -> JSON {
        URL(string: string).map(Self.url) ?? .null
    }
}
