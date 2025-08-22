import Foundation

public extension RBBJSON {
    static func load(from url: String) async throws -> RBBJSON {
        guard let url = URL(string: url) else {
            throw RBBJSONLoadingError.urlParsingFailed
        }

        return try await load(from: url)
    }

    static func load(from url: URL) async throws -> RBBJSON {
        switch url.scheme {
        case "http", "https":
            try await load(fromHTTPSURL: url)
        case "file":
            try load(fromFile: url)
        default:
            throw RBBJSONLoadingError.unknownScheme
        }
    }

    private static func load(fromHTTPSURL url: URL) async throws -> RBBJSON {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Accept": "application/json"]

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw RBBJSONLoadingError.unexpectedResponseType
        }

        func loadData() throws -> RBBJSON {
            try JSONDecoder().decode(RBBJSON.self, from: data)
        }

        switch response.statusCode {
        case 200 ... 299:
            break
        case 400 ... 499:
            throw RBBJSONLoadingError.clientHTTPError(response.statusCode, try? loadData())
        case 500 ... 599:
            throw RBBJSONLoadingError.serverHTTPError(response.statusCode, try? loadData())
        default:
            throw RBBJSONLoadingError.unexpectedHTTPResponse(response.statusCode, try? loadData())
        }

        return try loadData()
    }

    private static func load(fromFile url: URL) throws -> RBBJSON {
        try JSONDecoder().decode(RBBJSON.self, from: Data(contentsOf: url))
    }
}

enum RBBJSONLoadingError: Error {
    case unknownScheme
    case unexpectedResponseType
    case urlParsingFailed

    case clientHTTPError(Int, RBBJSON?)
    case serverHTTPError(Int, RBBJSON?)

    case unexpectedHTTPResponse(Int, RBBJSON?)
}
