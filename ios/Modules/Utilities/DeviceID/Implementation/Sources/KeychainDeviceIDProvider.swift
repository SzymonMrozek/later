import DependencyInjection
import DeviceIDInterface
import Foundation
import KeychainInterface

/// A random UUID kept in the keychain, so it outlives reinstalls but not a device wipe.
final class KeychainDeviceIDProvider: DeviceIDProvider {
    static let key = "device-id"

    @Dependency private var keychain: Keychain

    var deviceID: String {
        if let stored = keychain.data(for: Self.key).flatMap({ String(bytes: $0, encoding: .utf8) }), !stored.isEmpty {
            return stored
        }
        let id = UUID().uuidString
        // Without a stored ID the next launch creates another, and the API another guest.
        try? keychain.set(Data(id.utf8), for: Self.key)
        return id
    }
}
