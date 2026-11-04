import Account

public enum AuthenticationError: Error, Equatable, Sendable {
    /// The person closed the sign-in sheet; nothing to report.
    case cancelled
    /// The API couldn't be reached.
    case offline
    /// The API or Apple refused, or answered with something unexpected.
    case failed
}

/// Signs the person in, as a guest or with Apple, and remembers the account on this device.
public protocol AuthenticationService: AnyObject {
    /// The account from the last sign-in on this device, or nil before the first one. Read from the
    /// device, never the network.
    var currentAccount: Account? { get }

    /// Signs in with Apple. A guest account on this device becomes that Apple account, keeping its library.
    func signInWithApple() async throws(AuthenticationError) -> Account

    /// Starts using Later without an account: the API creates a guest account for this device, or
    /// returns the one it already has.
    func continueAsGuest() async throws(AuthenticationError) -> Account
}
