import DependencyInjection
import SessionStorageInterface

public enum SessionStorageImplementationModule {
    public static func register() {
        DependencyInjectionContainer.shared.register(.lazy { KeychainSessionStorage() }, for: SessionStorage.self)
    }
}
