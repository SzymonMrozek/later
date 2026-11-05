import BackgroundTaskInterface
import DependencyInjection

public enum BackgroundTaskImplementationModule {
    public static func register() {
        DependencyInjectionContainer.shared.register(
            .lazy { UIApplicationBackgroundTaskRunner() },
            for: BackgroundTaskRunner.self
        )
    }
}
