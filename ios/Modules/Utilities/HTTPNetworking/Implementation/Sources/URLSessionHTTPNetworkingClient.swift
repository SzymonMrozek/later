import Foundation
import HTTPNetworkingInterface

struct URLSessionHTTPNetworkingClient: HTTPNetworkingClient {
    let baseURL: URL
    let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func send(_ request: HTTPRequest) async throws(HTTPNetworkingError) {
        _ = try await data(for: request)
    }

    func send<Response: Decodable & Sendable>(
        _ request: HTTPRequest,
        decoding _: Response.Type
    ) async throws(HTTPNetworkingError) -> Response {
        let data = try await data(for: request)
        do {
            return try Self.decoder.decode(Response.self, from: data)
        } catch {
            throw .invalidResponse
        }
    }

    private func data(for request: HTTPRequest) async throws(HTTPNetworkingError) -> Data {
        let urlRequest = try Self.urlRequest(for: request, baseURL: baseURL)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw .unreachable
        }
        try Self.validate(response)
        return data
    }

    static func urlRequest(for request: HTTPRequest, baseURL: URL) throws(HTTPNetworkingError) -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appending(path: request.path))
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        for (field, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }
        if let body = request.body {
            do {
                urlRequest.httpBody = try encoder.encode(body)
            } catch {
                preconditionFailure("\(type(of: body)) can't be encoded as JSON: \(error)")
            }
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return urlRequest
    }

    static func validate(_ response: URLResponse) throws(HTTPNetworkingError) {
        guard let response = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        guard (200 ..< 300).contains(response.statusCode) else {
            throw .httpStatus(response.statusCode)
        }
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
