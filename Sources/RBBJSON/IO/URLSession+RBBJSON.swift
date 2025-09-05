import Foundation

public extension URLSession {
    func json(for request: URLRequest) async throws -> JSON {
        let (data, response) = try await data(for: request)

        return try JSON(data: data, urlResponse: response)
    }

    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    func json(for request: URLRequest, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> JSON {
        var request = request
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await data(for: request, delegate: delegate)

        return try JSON(data: data, urlResponse: response)
    }
}

public extension URLSession {
    func json(for url: URL) async throws -> JSON {
        try await json(for: URLRequest(url: url))
    }

    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    func json(for url: URL, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> JSON {
        try await json(for: URLRequest(url: url), delegate: delegate)
    }
}

public extension URLSession {
    func post(_ body: JSON, to url: URL) async throws -> JSON {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.httpBody = try JSONEncoder().encode(body)

        return try await json(for: request)
    }
}
