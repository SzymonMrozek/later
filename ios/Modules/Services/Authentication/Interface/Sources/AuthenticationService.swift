import Account

public enum AuthenticationError: Error, Equatable, Sendable {
    /// The person closed the sign-in sheet; nothing to report.
    case cancelled
    /// The API couldn't be reached.
    case offline
    /// The API or Apple refused, or answered with something unexpected.
    case failed
}

/// Why an API call made through `AuthenticationService.authorized` didn't return.
public enum AuthorizedCallError<Failure: Error>: Error {
    /// Nobody is signed in, or the session ended because the API refused to refresh it.
    case signedOut
    /// The session needed refreshing and the API couldn't be reached.
    case offline
    /// The session needed refreshing and the API answered with something unexpected.
    case failed
    /// The call itself failed, including a second 401 after a refresh.
    case call(Failure)
}

extension AuthorizedCallError: Equatable where Failure: Equatable {}

/// Signs the person in, as a guest or with Apple, remembers the session on this device and keeps
/// its access token fresh.
public protocol AuthenticationService: AnyObject {
    /// The account from the last sign-in on this device, or nil before the first one. Read from the
    /// device, never the network.
    var currentAccount: Account? { get }

    /// Signs in with Apple. A guest account on this device becomes that Apple account, keeping its library.
    func signInWithApple() async throws(AuthenticationError) -> Account

    /// Starts using Later without an account: the API creates a guest account for this device, or
    /// returns the one it already has.
    func continueAsGuest() async throws(AuthenticationError) -> Account

    /// Calls the API with the session's access token. Refreshes the session first when the token
    /// expires within a minute, and once more when `isUnauthorized` says the API answered 401, then
    /// calls again. Signs out when the API refuses the refresh token.
    func authorized<Value, Failure: Error>(
        _ call: (_ accessToken: String) async throws(Failure) -> Value,
        isUnauthorized: (Failure) -> Bool
    ) async throws(AuthorizedCallError<Failure>) -> Value
}
