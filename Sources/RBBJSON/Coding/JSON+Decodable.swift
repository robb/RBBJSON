import Foundation

public extension Decodable {
    init(json: JSON) throws {
        let data = try JSONEncoder().encode(json)

        self = try JSONDecoder().decode(Self.self, from: data)
    }
}
