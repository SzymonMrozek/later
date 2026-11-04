import Coordinator
import UIKit

/// The welcome screen, where the person signs in with Apple or continues without an account.
public protocol LoginEntryPoint {
    /// A coordinator that shows the welcome screen in `navigationController` once started, and calls
    /// `onLoggedIn` when the person has an account on this device.
    func attach(
        to navigationController: UINavigationController,
        onLoggedIn: @escaping @MainActor () -> Void
    ) -> Coordinator
}
