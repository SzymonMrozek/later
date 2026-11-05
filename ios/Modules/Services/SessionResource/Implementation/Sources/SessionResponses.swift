import Account
import Foundation
import Session
import SessionResourceInterface

nonisolated struct GuestSessionBody: Encodable, Equatable, Sendable {
    let deviceId: String
}

nonisolated struct AppleSessionBody: Encodable, Equatable, Sendable {
    let deviceId: String
    let identityToken: String
    let authorizationCode: String
    let givenName: String?
    let familyName: String?
    let email: String?

    init(_ credentials: AppleSessionCredentials) {
        deviceId = credentials.deviceID
        identityToken = credentials.identityToken
        authorizationCode = credentials.authorizationCode
        givenName = credentials.givenName
        familyName = credentials.familyName
        email = credentials.email
    }
}

nonisolated struct RefreshSessionBody: Encodable, Equatable, Sendable {
    let refreshToken: String
}

nonisolated struct SessionResponse: Decodable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let account: AccountResponse
}

nonisolated struct AccountResponse: Decodable, Equatable, Sendable {
    let id: String
    /// `guest` or `apple`.
    let kind: String
    let email: String?
}

extension Session {
    /// Nil when the response is missing a field or has an account kind the app doesn't know.
    init?(response: SessionResponse) {
        let account = response.account
        guard !response.accessToken.isEmpty, !response.refreshToken.isEmpty, !account.id.isEmpty else {
            return nil
        }
        let kind: Account.Kind
        switch account.kind {
        case "guest": kind = .guest
        case "apple": kind = .apple(email: account.email)
        default: return nil
        }
        self.init(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: response.expiresAt,
            account: Account(id: Account.ID(rawValue: account.id), kind: kind)
        )
    }
}
