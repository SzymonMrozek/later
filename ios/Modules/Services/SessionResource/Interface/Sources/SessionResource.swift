import Session

public enum SessionResourceError: Error, Equatable, Sendable {
    /// The API couldn't be reached.
    case unreachable
    /// The API refused the request, such as an Apple token that didn't verify or a refresh token
    /// that was already used.
    case rejected
    /// The API answered with something the app can't read.
    case invalidResponse
}

/// What Sign in with Apple gave the app, for the API to verify.
public nonisolated struct AppleSessionCredentials: Equatable, Sendable {
    public let deviceID: String
    public let identityToken: String
    public let authorizationCode: String
    public let givenName: String?
    public let familyName: String?
    public let email: String?

    public init(
        deviceID: String,
        identityToken: String,
        authorizationCode: String,
        givenName: String?,
        familyName: String?,
        email: String?
    ) {
        self.deviceID = deviceID
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
    }
}

/// The Later API's session endpoints (docs/api.md).
public protocol SessionResource {
    /// The guest session for this device, created on the first call.
    func createGuestSession(deviceID: String) async throws(SessionResourceError) -> Session

    /// A session for the Apple account; a guest account on `deviceID` becomes that account.
    func createAppleSession(_ credentials: AppleSessionCredentials) async throws(SessionResourceError) -> Session

    /// The next session for the same account. `refreshToken` and the access token issued with it
    /// stop working.
    func refreshSession(refreshToken: String) async throws(SessionResourceError) -> Session
}
