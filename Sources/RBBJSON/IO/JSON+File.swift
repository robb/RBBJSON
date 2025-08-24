import Foundation

public extension JSON {
    static func read(from url: URL) async throws -> JSON? {
        guard url.isFileURL else { throw JSON.IOError.unexpectedScheme }

        guard FileManager.default.fileExists(atPath: url.path) else { return nil }

        return try JSONDecoder().decode(JSON.self, from: Data(contentsOf: url))
    }

    static func write(_ json: JSON, to url: URL) throws {
        guard url.isFileURL else { throw JSON.IOError.unexpectedScheme }

        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)

        try JSONEncoder().encode(json).write(to: url)
    }
}
