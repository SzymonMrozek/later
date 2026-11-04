import Foundation
@testable import HTTPNetworkingImplementation
import HTTPNetworkingInterface
import Testing

struct URLSessionHTTPNetworkingClientTests {
    private struct Body: Encodable {
        let deviceId: String
    }

    private let baseURL = URL(string: "http://localhost:4000")!

    @Test func buildsAJSONRequestWithSnakeCaseKeys() throws {
        let request = try URLSessionHTTPNetworkingClient.urlRequest(
            for: HTTPRequest(
                .post,
                "/api/sessions/guest",
                headers: ["Authorization": "Bearer t"],
                body: Body(deviceId: "d1")
            ),
            baseURL: baseURL
        )
        #expect(request.url?.absoluteString == "http://localhost:4000/api/sessions/guest")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer t")
        let body = try #require(request.httpBody.flatMap { String(bytes: $0, encoding: .utf8) })
        #expect(body == #"{"device_id":"d1"}"#)
    }

    @Test func leavesTheBodyOutWhenThereIsNone() throws {
        let request = try URLSessionHTTPNetworkingClient.urlRequest(
            for: HTTPRequest(.get, "/api/health"),
            baseURL: baseURL
        )
        #expect(request.httpBody == nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
    }

    @Test(arguments: [200, 201, 204, 299])
    func acceptsSuccessStatuses(_ status: Int) throws {
        try URLSessionHTTPNetworkingClient.validate(response(status))
    }

    @Test(arguments: [301, 400, 401, 404, 422, 500])
    func rejectsOtherStatuses(_ status: Int) {
        #expect(throws: HTTPNetworkingError.httpStatus(status)) {
            try URLSessionHTTPNetworkingClient.validate(response(status))
        }
    }

    private func response(_ status: Int) -> URLResponse {
        HTTPURLResponse(url: baseURL, statusCode: status, httpVersion: nil, headerFields: nil) ?? URLResponse()
    }
}
