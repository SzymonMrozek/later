import AuthenticationInterface
import Coordinator
import DependencyInjection
import LaterCatalog
import LoginInterface
import SwiftUI
import UIKit

/// Chooses the app's root and swaps it when the person signs in.
public final class AppCoordinator {
    let rootViewController = AppRootViewController()
    private let launch: AppLaunch
    private var activeCoordinator: Coordinator?

    init(launch: AppLaunch = .current) {
        self.launch = launch
    }

    func start() {
        @Dependency var authentication: AuthenticationService
        switch launch {
        case .mainApp where authentication.currentAccount == nil:
            showLogin()
        case .mainApp:
            showSignedIn(animated: false)
        #if DEBUG
            case .catalog:
                showSignedIn(animated: false)
        #endif
        }
    }

    private func showLogin() {
        @Dependency var login: LoginEntryPoint
        let navigationController = UINavigationController()
        let coordinator = login.attach(to: navigationController) { [weak self] in
            self?.showSignedIn(animated: true)
        }
        coordinator.start()
        activeCoordinator = coordinator
        rootViewController.show(navigationController, animated: false)
    }

    /// The design system catalog stands in for the signed-in app until its first scene lands.
    private func showSignedIn(animated: Bool) {
        activeCoordinator = nil
        rootViewController.show(UIHostingController(rootView: LaterCatalogView()), animated: animated)
    }
}

/// Hosts one root at a time and cross-fades to the next.
final class AppRootViewController: UIViewController {
    private(set) var current: UIViewController?

    func show(_ next: UIViewController, animated: Bool) {
        let previous = current
        current = next
        addChild(next)
        next.view.frame = view.bounds
        next.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(next.view)
        next.didMove(toParent: self)
        guard let previous else {
            return
        }
        previous.willMove(toParent: nil)
        let remove = {
            previous.view.removeFromSuperview()
            previous.removeFromParent()
        }
        guard animated else {
            remove()
            return
        }
        next.view.alpha = 0
        UIView.animate(withDuration: 0.3, animations: { next.view.alpha = 1 }, completion: { _ in remove() })
    }
}
