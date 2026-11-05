import Account
import DependencyInjection
import DependencyInjectionTestSupport
import Foundation
import HTTPNetworkingInterface
import Session
@testable import SessionResourceImplementation
import SessionResourceInterface
import Testing

@Suite(.dependencyContainer)
struct SessionResourceImplTests {
    private static let expiresAt = Date(timeIntervalSince1970: 1_800_000_000)
    private let guestResponse = SessionResponse(
        accessToken: "t1",
        refreshToken: "r1",
        expiresAt: expiresAt,
        account: AccountResponse(id: "a1", kind: "guest", email: nil)
    )

    @Test func createsAGuestSession() async throws {
        let http = install(.success(guestResponse))

        let session = try await SessionResourceImpl().createGuestSession(deviceID: "d1")

        #expect(session == Session(
            accessToken: "t1",
            refreshToken: "r1",
            expiresAt: Self.expiresAt,
            account: Account(id: .init(rawValue: "a1"), kind: .guest)
        ))
        let request = try #require(http.requests.first)
        #expect(request.method == .post)
        #expect(request.path == "/api/sessions/guest")
        #expect(request.body as? GuestSessionBody == GuestSessionBody(deviceId: "d1"))
    }

    @Test func createsAnAppleSessionSendingTheCredentials() async throws {
        let http = install(.success(SessionResponse(
            accessToken: "t2",
            refreshToken: "r2",
            expiresAt: Self.expiresAt,
            account: AccountResponse(id: "a1", kind: "apple", email: "me@example.com")
        )))
        let credentials = AppleSessionCredentials(
            deviceID: "d1",
            identityToken: "jwt",
            authorizationCode: "code",
            givenName: "Ada",
            familyName: "Lovelace",
            email: "me@example.com"
        )

        let session = try await SessionResourceImpl().createAppleSession(credentials)

        #expect(session.account.kind == .apple(email: "me@example.com"))
        let request = try #require(http.requests.first)
        #expect(request.path == "/api/sessions/apple")
        #expect(request.body as? AppleSessionBody == AppleSessionBody(credentials))
    }

    @Test func refreshesASessionSendingTheRefreshToken() async throws {
        let http = install(.success(guestResponse))

        let session = try await SessionResourceImpl().refreshSession(refreshToken: "r0")

        #expect(session.accessToken == "t1")
        #expect(session.refreshToken == "r1")
        let request = try #require(http.requests.first)
        #expect(request.method == .post)
        #expect(request.path == "/api/sessions/refresh")
        #expect(request.body as? RefreshSessionBody == RefreshSessionBody(refreshToken: "r0"))
    }

    @Test func aRefreshTokenTheAPIRefusesIsRejected() async {
        install(.failure(.httpStatus(401)))
        await #expect(throws: SessionResourceError.rejected) {
            try await SessionResourceImpl().refreshSession(refreshToken: "r0")
        }
    }

    @Test(arguments: [
        (HTTPNetworkingError.unreachable, SessionResourceError.unreachable),
        (.httpStatus(401), .rejected),
        (.httpStatus(422), .rejected),
        (.invalidResponse, .invalidResponse),
    ])
    func mapsHTTPErrors(_ error: HTTPNetworkingError, to expected: SessionResourceError) async {
        install(.failure(error))
        await #expect(throws: expected) { try await SessionResourceImpl().createGuestSession(deviceID: "d1") }
    }

    @Test(arguments: [
        AccountResponse(id: "a1", kind: "google", email: nil),
        AccountResponse(id: "", kind: "guest", email: nil),
    ])
    func rejectsAnAccountTheAppCantRead(_ account: AccountResponse) async {
        install(.success(SessionResponse(
            accessToken: "t",
            refreshToken: "r",
            expiresAt: Self.expiresAt,
            account: account
        )))
        await #expect(throws: SessionResourceError.invalidResponse) {
            try await SessionResourceImpl().createGuestSession(deviceID: "d1")
        }
    }

    @Test(arguments: [("", "r"), ("t", "")])
    func rejectsAResponseWithoutTokens(_ accessToken: String, _ refreshToken: String) async {
        install(.success(SessionResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: Self.expiresAt,
            account: AccountResponse(id: "a1", kind: "guest", email: nil)
        )))
        await #expect(throws: SessionResourceError.invalidResponse) {
            try await SessionResourceImpl().createGuestSession(deviceID: "d1")
        }
    }

    @discardableResult
    private func install(_ result: Result<SessionResponse, HTTPNetworkingError>) -> FakeHTTPNetworkingClient {
        let http = FakeHTTPNetworkingClient(result: result)
        DependencyInjectionContainer.testScoped.register(.eager(http), for: HTTPNetworkingClient.self)
        return http
    }
}

/// Answers every request with `result` and records what was sent.
final class FakeHTTPNetworkingClient: HTTPNetworkingClient {
    let result: Result<SessionResponse, HTTPNetworkingError>
    private(set) var requests: [HTTPRequest] = []

    init(result: Result<SessionResponse, HTTPNetworkingError>) {
        self.result = result
    }

    func send(_ request: HTTPRequest) async throws(HTTPNetworkingError) {
        requests.append(request)
        _ = try result.get()
    }

    func send<Response: Decodable & Sendable>(
        _ request: HTTPRequest,
        decoding _: Response.Type
    ) async throws(HTTPNetworkingError) -> Response {
        requests.append(request)
        guard let response = try result.get() as? Response else {
            throw .invalidResponse
        }
        return response
    }
}
