import Account
import DependencyInjection
import DependencyInjectionTestSupport
import Foundation
import KeychainInterface
import Session
@testable import SessionStorageImplementation
import SessionStorageInterface
import Testing

@Suite(.dependencyContainer)
struct KeychainSessionStorageTests {
    @Test(arguments: [
        session("1", .guest),
        session("2", .apple(email: "me@example.com")),
        session("3", .apple(email: nil)),
    ])
    func keepsASessionAcrossInstances(_ session: Session) throws {
        let keychain = install()
        try KeychainSessionStorage().store(session)

        #expect(KeychainSessionStorage().session == session)
        #expect(keychain.items[KeychainSessionStorage.key] != nil)
    }

    @Test func hasNoSessionBeforeOneIsStored() {
        install()
        #expect(KeychainSessionStorage().session == nil)
    }

    @Test func storingNilRemovesTheSession() throws {
        let keychain = install()
        let storage = KeychainSessionStorage()
        try storage.store(session("1", .guest))

        try storage.store(nil)

        #expect(storage.session == nil)
        #expect(keychain.items.isEmpty)
    }

    @Test func ignoresUnreadableData() {
        let keychain = install()
        keychain.items[KeychainSessionStorage.key] = Data("not json".utf8)
        #expect(KeychainSessionStorage().session == nil)
    }

    @Test func reportsAKeychainFailure() {
        let keychain = install()
        keychain.failure = KeychainError(status: -25299)
        #expect(throws: SessionStorageError()) {
            try KeychainSessionStorage().store(session("1", .guest))
        }
    }

    @Test func ignoresASessionStoredWithoutARefreshToken() {
        let keychain = install()
        keychain.items[KeychainSessionStorage.key] = Data(#"{"token":"t","accountID":"a","isGuest":true}"#.utf8)
        #expect(KeychainSessionStorage().session == nil)
    }

    @discardableResult
    private func install() -> InMemoryKeychain {
        let keychain = InMemoryKeychain()
        DependencyInjectionContainer.testScoped.register(.eager(keychain), for: Keychain.self)
        return keychain
    }
}

private nonisolated func session(_ suffix: String, _ kind: Account.Kind) -> Session {
    Session(
        accessToken: "t\(suffix)",
        refreshToken: "r\(suffix)",
        // Whole seconds, as the API sends them.
        expiresAt: Date(timeIntervalSince1970: 1_800_000_000),
        account: Account(id: .init(rawValue: "a\(suffix)"), kind: kind)
    )
}

final class InMemoryKeychain: Keychain {
    var items: [String: Data] = [:]
    var failure: KeychainError?

    func data(for key: String) -> Data? {
        items[key]
    }

    func set(_ data: Data?, for key: String) throws(KeychainError) {
        if let failure {
            throw failure
        }
        items[key] = data
    }
}
