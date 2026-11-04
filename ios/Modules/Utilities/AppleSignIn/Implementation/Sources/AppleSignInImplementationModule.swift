import AppleSignInInterface
import DependencyInjection

public enum AppleSignInImplementationModule {
    public static func register() {
        DependencyInjectionContainer.shared.register(
            .lazy { AuthenticationServicesAppleSignInClient() },
            for: AppleSignInClient.self
        )
    }
}
