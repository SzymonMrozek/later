/// Which root the app opens on.
enum AppLaunch {
    /// Welcome without an account on this device, the app with one.
    case mainApp

    #if DEBUG
        /// The design system catalog, without signing in.
        case catalog
    #endif

    #if DEBUG
        /// Change this while working on one part of the app; keep `.mainApp` in commits.
        static let current = AppLaunch.mainApp
    #else
        static let current = AppLaunch.mainApp
    #endif
}
