import DependencyInjection
import DependencyInjectionTestSupport
@testable import DeviceIDImplementation
import DeviceIDInterface
import Foundation
import KeychainInterface
import Testing

@Suite(.dependencyContainer)
struct KeychainDeviceIDProviderTests {
    @Test func createsAnIDOnceAndKeepsIt() {
        let keychain = install()

        let first = KeychainDeviceIDProvider().deviceID
        let second = KeychainDeviceIDProvider().deviceID

        #expect(UUID(uuidString: first) != nil)
        #expect(first == second)
        #expect(keychain.items[KeychainDeviceIDProvider.key] == Data(first.utf8))
    }

    @Test func usesAnIDAlreadyStored() {
        let keychain = install()
        keychain.items[KeychainDeviceIDProvider.key] = Data("stored".utf8)
        #expect(KeychainDeviceIDProvider().deviceID == "stored")
    }

    private func install() -> InMemoryKeychain {
        let keychain = InMemoryKeychain()
        DependencyInjectionContainer.testScoped.register(.eager(keychain), for: Keychain.self)
        return keychain
    }
}

final class InMemoryKeychain: Keychain {
    var items: [String: Data] = [:]

    func data(for key: String) -> Data? {
        items[key]
    }

    func set(_ data: Data?, for key: String) throws(KeychainError) {
        items[key] = data
    }
}
