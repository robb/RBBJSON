import Foundation

extension JSON {
    init<T: Encodable>(encoding value: T) throws {
        let data = try JSONEncoder().encode(value)

        self = try JSONDecoder().decode(Self.self, from: data)
    }
}
