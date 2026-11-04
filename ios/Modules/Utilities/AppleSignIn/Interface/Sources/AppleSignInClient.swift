import Foundation

/// What Sign in with Apple returns. The server verifies `identityToken` with Apple.
public nonisolated struct AppleIDCredential: Equatable, Sendable {
    /// A JWT signed by Apple that identifies the person to this app.
    public let identityToken: String
    /// A one-time code the server can exchange for Apple refresh tokens.
    public let authorizationCode: String
    /// Only on the first sign-in, and only if the person shares them.
    public let givenName: String?
    public let familyName: String?
    public let email: String?

    public init(
        identityToken: String,
        authorizationCode: String,
        givenName: String? = nil,
        familyName: String? = nil,
        email: String? = nil
    ) {
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
    }
}

public enum AppleSignInError: Error, Equatable, Sendable {
    /// The person closed Apple's sheet.
    case cancelled
    /// Apple couldn't sign the person in, for example without an Apple Account on the device.
    case failed
}

public protocol AppleSignInClient {
    /// Shows Apple's sign-in sheet and returns once the person finishes or closes it.
    func signIn() async throws(AppleSignInError) -> AppleIDCredential
}
