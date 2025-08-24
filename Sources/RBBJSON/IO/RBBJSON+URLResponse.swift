import Foundation

extension JSON {
    init(data: Data, urlResponse response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse else {
            throw RBBJSONLoadingError.unexpectedResponseType
        }

        func loadData() throws -> JSON {
            try JSONDecoder().decode(JSON.self, from: data)
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

        self = try loadData()
    }
}

enum RBBJSONLoadingError: Error {
    case unknownScheme
    case unexpectedResponseType
    case urlParsingFailed

    case clientHTTPError(Int, JSON?)
    case serverHTTPError(Int, JSON?)

    case unexpectedHTTPResponse(Int, JSON?)
}
