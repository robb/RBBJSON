import Foundation

extension JSON {
    init(data: Data, urlResponse response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse else {
            throw JSON.IOError.unexpectedResponseType
        }

        func loadData() throws -> JSON {
            try JSONDecoder().decode(JSON.self, from: data)
        }

        switch response.statusCode {
        case 200 ... 299:
            break
        case 400 ... 499:
            throw JSON.IOError.clientHTTPError(response.statusCode, try? loadData())
        case 500 ... 599:
            throw JSON.IOError.serverHTTPError(response.statusCode, try? loadData())
        default:
            throw JSON.IOError.unexpectedHTTPResponse(response.statusCode, try? loadData())
        }

        self = try loadData()
    }
}

extension JSON {
    enum IOError: Error {
        case unknownScheme
        case unexpectedScheme
        case unexpectedResponseType
        case urlParsingFailed

        case clientHTTPError(Int, JSON?)
        case serverHTTPError(Int, JSON?)

        case unexpectedHTTPResponse(Int, JSON?)
    }
}
