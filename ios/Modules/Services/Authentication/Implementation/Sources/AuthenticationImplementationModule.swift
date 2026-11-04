import AuthenticationInterface
import DependencyInjection

public enum AuthenticationImplementationModule {
    public static func register() {
        DependencyInjectionContainer.shared.register(
            .lazy { AuthenticationServiceImpl() },
            for: AuthenticationService.self
        )
    }
}
