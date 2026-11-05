import AppleSignInImplementation
import AuthenticationImplementation
import BackgroundTaskImplementation
import DeviceIDImplementation
import HTTPNetworkingImplementation
import KeychainImplementation
import LoginImplementation
import SessionResourceImplementation
import SessionStorageImplementation

/// Selects the implementation of every contract the app uses. The only module that imports
/// implementations; each one owns how it's built in its own `register()`.
public enum AppCompositionModule {
    public static func register() {
        KeychainImplementationModule.register()
        HTTPNetworkingImplementationModule.register()
        SessionStorageImplementationModule.register()
        DeviceIDImplementationModule.register()
        AppleSignInImplementationModule.register()
        BackgroundTaskImplementationModule.register()
        SessionResourceImplementationModule.register()
        AuthenticationImplementationModule.register()
        LoginImplementationModule.register()
    }
}
