import Account

/// A signed-in session: the account and the token that authorizes its API requests.
public nonisolated struct Session: Equatable, Sendable {
    /// Sent as `Authorization: Bearer <token>`.
    public let token: String
    public let account: Account

    public init(token: String, account: Account) {
        self.token = token
        self.account = account
    }
}
