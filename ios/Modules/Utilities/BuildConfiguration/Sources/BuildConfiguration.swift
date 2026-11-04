import Foundation

/// Values the build bakes into the app's Info.plist.
public struct BuildConfiguration: Equatable, Sendable {
    /// The Later API, such as `http://localhost:4000` for a worktree's development server.
    public let apiBaseURL: URL

    public init(apiBaseURL: URL) {
        self.apiBaseURL = apiBaseURL
    }

    /// The running app's configuration. A build without it can't reach the API, so that's fatal.
    public static var main: BuildConfiguration {
        guard let configuration = BuildConfiguration(infoDictionary: Bundle.main.infoDictionary ?? [:]) else {
            preconditionFailure("The app's Info.plist has no valid LaterAPIBaseURL.")
        }
        return configuration
    }

    init?(infoDictionary: [String: Any]) {
        guard let string = infoDictionary["LaterAPIBaseURL"] as? String,
              let url = URL(string: string),
              url.scheme == "http" || url.scheme == "https",
              url.host() != nil
        else {
            return nil
        }
        self.init(apiBaseURL: url)
    }
}
