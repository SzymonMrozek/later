import DependencyInjection
import HTTPNetworkingInterface
import Session
import SessionResourceInterface

/// Sends the session requests and maps the responses to `Session`. The API's request and response
/// types stay in this file.
final class SessionResourceImpl: SessionResource {
    enum Endpoint {
        static let guest = "/api/sessions/guest"
        static let apple = "/api/sessions/apple"
        static let refresh = "/api/sessions/refresh"
    }

    @Dependency private var http: HTTPNetworkingClient

    func createGuestSession(deviceID: String) async throws(SessionResourceError) -> Session {
        try await createSession(at: Endpoint.guest, body: GuestSessionBody(deviceId: deviceID))
    }

    func createAppleSession(_ credentials: AppleSessionCredentials) async throws(SessionResourceError) -> Session {
        try await createSession(at: Endpoint.apple, body: AppleSessionBody(credentials))
    }

    func refreshSession(refreshToken: String) async throws(SessionResourceError) -> Session {
        try await createSession(at: Endpoint.refresh, body: RefreshSessionBody(refreshToken: refreshToken))
    }

    private func createSession(
        at path: String,
        body: some Encodable & Sendable
    ) async throws(SessionResourceError) -> Session {
        let response: SessionResponse
        do throws(HTTPNetworkingError) {
            response = try await http.send(HTTPRequest(.post, path, body: body), decoding: SessionResponse.self)
        } catch {
            switch error {
            case .unreachable: throw .unreachable
            case .httpStatus: throw .rejected
            case .invalidResponse: throw .invalidResponse
            }
        }
        guard let session = Session(response: response) else {
            throw .invalidResponse
        }
        return session
    }
}
