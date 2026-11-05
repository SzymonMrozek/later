import Account
import DependencyInjection
import Foundation
import KeychainInterface
import Session
import SessionStorageInterface

/// The session as JSON in one keychain item.
final class KeychainSessionStorage: SessionStorage {
    static let key = "session"

    @Dependency private var keychain: Keychain

    var session: Session? {
        keychain.data(for: Self.key)
            .flatMap { try? JSONDecoder().decode(StoredSession.self, from: $0) }
            .flatMap(\.session)
    }

    func store(_ session: Session?) throws(SessionStorageError) {
        do {
            try keychain.set(session.map { try JSONEncoder().encode(StoredSession($0)) }, for: Self.key)
        } catch {
            throw SessionStorageError()
        }
    }
}

/// How a session is written to the device. Its own format, so storage doesn't change when the API does.
private nonisolated struct StoredSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let accountID: String
    let isGuest: Bool
    let email: String?

    init(_ session: Session) {
        accessToken = session.accessToken
        refreshToken = session.refreshToken
        expiresAt = session.expiresAt
        accountID = session.account.id.rawValue
        switch session.account.kind {
        case .guest:
            isGuest = true
            email = nil
        case let .apple(email):
            isGuest = false
            self.email = email
        }
    }

    var session: Session? {
        guard !accessToken.isEmpty, !refreshToken.isEmpty, !accountID.isEmpty else {
            return nil
        }
        let kind: Account.Kind = isGuest ? .guest : .apple(email: email)
        return Session(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            account: Account(id: Account.ID(rawValue: accountID), kind: kind)
        )
    }
}
