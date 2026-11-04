import Coordinator
import SwiftUI
import UIKit

/// What the interactor asks of navigation.
protocol LoginCoordinator: AnyObject {
    func handleLoggedIn()
}

final class LoginCoordinatorImpl: Coordinator, LoginCoordinator {
    unowned let navigationController: UINavigationController
    private let onLoggedIn: @MainActor () -> Void

    init(navigationController: UINavigationController, onLoggedIn: @escaping @MainActor () -> Void) {
        self.navigationController = navigationController
        self.onLoggedIn = onLoggedIn
    }

    func start() {
        let viewModel = LoginViewModel()
        let interactor = LoginInteractorImpl(viewModel: viewModel, coordinator: self)
        let view = LoginView(viewModel: viewModel, interactor: interactor)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(UIHostingController(rootView: view), animated: false)
    }

    func handleLoggedIn() {
        onLoggedIn()
    }
}
