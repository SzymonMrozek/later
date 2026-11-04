import DependencyInjection
import DeviceIDInterface

public enum DeviceIDImplementationModule {
    public static func register() {
        DependencyInjectionContainer.shared.register(.lazy { KeychainDeviceIDProvider() }, for: DeviceIDProvider.self)
    }
}
