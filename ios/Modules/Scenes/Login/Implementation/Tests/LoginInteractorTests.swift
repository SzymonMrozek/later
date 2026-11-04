import Account
import AuthenticationInterface
import DependencyInjection
import DependencyInjectionTestSupport
@testable import LoginImplementation
import Testing

@Suite(.dependencyContainer)
struct LoginInteractorTests {
    private let account = Account(id: .init(rawValue: "a1"), kind: .guest)

    @Test func continuingAsGuestFinishesLogin() async {
        let authentication = install(FakeAuthenticationService(result: .success(account)))
        let coordinator = FakeLoginCoordinator()
        let viewModel = LoginViewModel()
        let interactor = LoginInteractorImpl(viewModel: viewModel, coordinator: coordinator)

        await interactor.continueAsGuest()

        #expect(authentication.calls == [.guest])
        #expect(coordinator.loggedIn == 1)
        #expect(viewModel.state == .idle)
    }

    @Test func signingInWithAppleFinishesLogin() async {
        let authentication = install(FakeAuthenticationService(result: .success(account)))
        let coordinator = FakeLoginCoordinator()

        await LoginInteractorImpl(viewModel: LoginViewModel(), coordinator: coordinator).signInWithApple()

        #expect(authentication.calls == [.apple])
        #expect(coordinator.loggedIn == 1)
    }

    @Test func closingApplesSheetLeavesTheScreenAsItWas() async {
        install(FakeAuthenticationService(result: .failure(.cancelled)))
        let coordinator = FakeLoginCoordinator()
        let viewModel = LoginViewModel()
        let interactor = LoginInteractorImpl(viewModel: viewModel, coordinator: coordinator)

        await interactor.signInWithApple()

        #expect(viewModel.state == .idle)
        #expect(coordinator.loggedIn == 0)
    }

    @Test(arguments: [
        (AuthenticationError.offline, LoginFailure.offline),
        (.failed, .failed),
    ])
    func aFailureStaysOnTheScreen(error: AuthenticationError, failure: LoginFailure) async {
        install(FakeAuthenticationService(result: .failure(error)))
        let coordinator = FakeLoginCoordinator()
        let viewModel = LoginViewModel()
        let interactor = LoginInteractorImpl(viewModel: viewModel, coordinator: coordinator)

        await interactor.continueAsGuest()

        #expect(viewModel.state == .failed(failure))
        #expect(coordinator.loggedIn == 0)
    }

    @Test func showsWhichSignInIsRunningAndIgnoresAnotherTap() async {
        let authentication = install(FakeAuthenticationService(result: .success(account), suspends: true))
        let coordinator = FakeLoginCoordinator()
        let viewModel = LoginViewModel()
        let interactor = LoginInteractorImpl(viewModel: viewModel, coordinator: coordinator)

        let first = Task { await interactor.continueAsGuest() }
        await authentication.waitForCall()
        #expect(viewModel.state == .signingIn(.guest))

        await interactor.signInWithApple()
        #expect(authentication.calls == [.guest])

        authentication.resume()
        await first.value
        #expect(coordinator.loggedIn == 1)
    }

    @discardableResult
    private func install(_ authentication: FakeAuthenticationService) -> FakeAuthenticationService {
        DependencyInjectionContainer.testScoped.register(.eager(authentication), for: AuthenticationService.self)
        return authentication
    }
}

private final class FakeLoginCoordinator: LoginCoordinator {
    private(set) var loggedIn = 0

    func handleLoggedIn() {
        loggedIn += 1
    }
}

private final class FakeAuthenticationService: AuthenticationService {
    enum Call: Equatable {
        case apple
        case guest
    }

    let currentAccount: Account? = nil
    private(set) var calls: [Call] = []
    private let result: Result<Account, AuthenticationError>
    private let suspends: Bool
    private var called: CheckedContinuation<Void, Never>?
    private var gate: CheckedContinuation<Void, Never>?

    init(result: Result<Account, AuthenticationError>, suspends: Bool = false) {
        self.result = result
        self.suspends = suspends
    }

    func signInWithApple() async throws(AuthenticationError) -> Account {
        try await answer(.apple)
    }

    func continueAsGuest() async throws(AuthenticationError) -> Account {
        try await answer(.guest)
    }

    /// Returns once a sign-in has started.
    func waitForCall() async {
        guard calls.isEmpty else {
            return
        }
        await withCheckedContinuation { called = $0 }
    }

    func resume() {
        gate?.resume()
        gate = nil
    }

    private func answer(_ call: Call) async throws(AuthenticationError) -> Account {
        calls.append(call)
        called?.resume()
        called = nil
        if suspends {
            await withCheckedContinuation { gate = $0 }
        }
        return try result.get()
    }
}
