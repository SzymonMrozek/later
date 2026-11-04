import Coordinator
import LoginInterface
import UIKit

struct LoginEntryPointImpl: LoginEntryPoint {
    func attach(
        to navigationController: UINavigationController,
        onLoggedIn: @escaping @MainActor () -> Void
    ) -> Coordinator {
        LoginCoordinatorImpl(navigationController: navigationController, onLoggedIn: onLoggedIn)
    }
}
