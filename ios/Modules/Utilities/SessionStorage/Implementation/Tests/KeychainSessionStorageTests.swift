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
        Session(token: "t1", account: Account(id: .init(rawValue: "a1"), kind: .guest)),
        Session(token: "t2", account: Account(id: .init(rawValue: "a2"), kind: .apple(email: "me@example.com"))),
        Session(token: "t3", account: Account(id: .init(rawValue: "a3"), kind: .apple(email: nil))),
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
        try storage.store(Session(token: "t", account: Account(id: .init(rawValue: "a"), kind: .guest)))

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
            try KeychainSessionStorage().store(Session(
                token: "t",
                account: Account(id: .init(rawValue: "a"), kind: .guest)
            ))
        }
    }

    @discardableResult
    private func install() -> InMemoryKeychain {
        let keychain = InMemoryKeychain()
        DependencyInjectionContainer.testScoped.register(.eager(keychain), for: Keychain.self)
        return keychain
    }
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
