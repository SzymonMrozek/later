import Account
import Foundation

/// A signed-in session: the account, the short-lived token that authorizes its API requests and
/// the token that renews it.
public nonisolated struct Session: Equatable, Sendable {
    /// Sent as `Authorization: Bearer <accessToken>` until `expiresAt`.
    public let accessToken: String
    /// Traded once for the next session, before `expiresAt` or after the API rejects `accessToken`.
    public let refreshToken: String
    public let expiresAt: Date
    public let account: Account

    public init(accessToken: String, refreshToken: String, expiresAt: Date, account: Account) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.account = account
    }
}
