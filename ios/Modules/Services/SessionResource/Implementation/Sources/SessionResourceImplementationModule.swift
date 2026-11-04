import DependencyInjection
import SessionResourceInterface

public enum SessionResourceImplementationModule {
    public static func register() {
        DependencyInjectionContainer.shared.register(.lazy { SessionResourceImpl() }, for: SessionResource.self)
    }
}
