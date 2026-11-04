import Account
import AuthenticationInterface
import DependencyInjection

protocol LoginInteractor {
    func signInWithApple() async
    func continueAsGuest() async
}

final class LoginInteractorImpl: LoginInteractor {
    private let viewModel: LoginViewModel
    private let coordinator: LoginCoordinator

    init(viewModel: LoginViewModel, coordinator: LoginCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    func signInWithApple() async {
        await signIn(with: .apple) { authentication async throws(AuthenticationError) in
            try await authentication.signInWithApple()
        }
    }

    func continueAsGuest() async {
        await signIn(with: .guest) { authentication async throws(AuthenticationError) in
            try await authentication.continueAsGuest()
        }
    }

    /// One sign-in at a time. Closing Apple's sheet returns to the screen as it was.
    private func signIn(
        with method: LoginMethod,
        _ operation: @MainActor (AuthenticationService) async throws(AuthenticationError) -> Account
    ) async {
        @Dependency var authentication: AuthenticationService
        guard !viewModel.state.isSigningIn else {
            return
        }
        viewModel.state = .signingIn(method)
        do throws(AuthenticationError) {
            _ = try await operation(authentication)
            viewModel.state = .idle
            coordinator.handleLoggedIn()
        } catch {
            viewModel.state = switch error {
            case .cancelled: .idle
            case .offline: .failed(.offline)
            case .failed: .failed(.failed)
            }
        }
    }
}
