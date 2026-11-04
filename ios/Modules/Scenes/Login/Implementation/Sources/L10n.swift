import Foundation

/// The welcome screen's copy, translated in Resources/Localizable.xcstrings.
enum L10n {
    static let title = String(
        localized: "login.title",
        defaultValue: "Save it now. Listen later, in the time you actually have.",
        bundle: .module
    )
    static let subtitle = String(
        localized: "login.subtitle",
        defaultValue: """
        Share a link from any app or paste it here. Later prepares a summary or the full article in your language.
        """,
        bundle: .module
    )
    static let continueWithApple = String(
        localized: "login.continueWithApple",
        defaultValue: "Continue with Apple",
        bundle: .module
    )
    static let continueWithoutAccount = String(
        localized: "login.continueWithoutAccount",
        defaultValue: "Try without an account",
        bundle: .module
    )
    static let accountLater = String(
        localized: "login.accountLater",
        defaultValue: "You can create an account later in Settings.",
        bundle: .module
    )
    static let offlineTitle = String(localized: "login.offline.title", defaultValue: "You're offline", bundle: .module)
    static let offlineMessage = String(
        localized: "login.offline.message",
        defaultValue: "Connect to the internet and try again.",
        bundle: .module
    )
    static let failedTitle = String(
        localized: "login.failed.title",
        defaultValue: "Couldn't sign you in",
        bundle: .module
    )
    static let failedMessage = String(
        localized: "login.failed.message",
        defaultValue: "Something went wrong on our side. Try again in a moment.",
        bundle: .module
    )
}
