import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// A request to the Later API. The client adds the base URL and speaks JSON with snake_case keys,
/// so request and response types use Swift names.
public struct HTTPRequest: Sendable {
    public let method: HTTPMethod
    /// The path under the API's base URL, such as `/api/sessions/guest`.
    public let path: String
    public let headers: [String: String]
    public let body: (any Encodable & Sendable)?

    public init(
        _ method: HTTPMethod,
        _ path: String,
        headers: [String: String] = [:],
        body: (any Encodable & Sendable)? = nil
    ) {
        self.method = method
        self.path = path
        self.headers = headers
        self.body = body
    }
}

public enum HTTPNetworkingError: Error, Equatable, Sendable {
    /// No response: offline, timed out, or the server isn't running.
    case unreachable
    /// The server answered outside 200–299.
    case httpStatus(Int)
    /// The response couldn't be read as the expected type.
    case invalidResponse
}

public protocol HTTPNetworkingClient: Sendable {
    /// Sends a request whose response has no body the caller needs.
    func send(_ request: HTTPRequest) async throws(HTTPNetworkingError)

    /// Sends a request and decodes its JSON response.
    func send<Response: Decodable & Sendable>(
        _ request: HTTPRequest,
        decoding _: Response.Type
    ) async throws(HTTPNetworkingError) -> Response
}
