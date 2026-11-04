import DependencyInjection
import Foundation
import KeychainInterface

public enum KeychainImplementationModule {
    public static func register() {
        DependencyInjectionContainer.shared.register(
            .lazy { SecurityKeychain(service: Bundle.main.bundleIdentifier ?? "dev.mrozek.later") },
            for: Keychain.self
        )
    }
}
