import DependencyInjection
import LoginInterface

public enum LoginImplementationModule {
    public static func register() {
        DependencyInjectionContainer.shared.register(.lazy { LoginEntryPointImpl() }, for: LoginEntryPoint.self)
    }
}
