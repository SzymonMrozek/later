import BuildConfiguration
import DependencyInjection
import HTTPNetworkingInterface

public enum HTTPNetworkingImplementationModule {
    public static func register() {
        DependencyInjectionContainer.shared.register(
            .lazy { URLSessionHTTPNetworkingClient(baseURL: BuildConfiguration.main.apiBaseURL) },
            for: HTTPNetworkingClient.self
        )
    }
}
