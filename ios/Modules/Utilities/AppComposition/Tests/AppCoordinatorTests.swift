import Account
@testable import AppComposition
import AuthenticationInterface
import Coordinator
import DependencyInjection
import DependencyInjectionTestSupport
import LoginInterface
import Testing
import UIKit

@Suite(.dependencyContainer)
struct AppCoordinatorTests {
    @Test func opensWelcomeWithoutAnAccount() {
        let login = install(account: nil)
        let app = AppCoordinator(launch: .mainApp)

        app.start()

        #expect(login.coordinators.count == 1)
        #expect(login.coordinators.first?.started == true)
        #expect(app.rootViewController.current === login.coordinators.first?.navigationController)
    }

    @Test func opensTheAppWithAnAccount() {
        let login = install(account: Account(id: .init(rawValue: "a1"), kind: .guest))
        let app = AppCoordinator(launch: .mainApp)

        app.start()

        #expect(login.coordinators.isEmpty)
        #expect(app.rootViewController.current != nil)
        #expect(!(app.rootViewController.current is UINavigationController))
    }

    @Test func signingInReplacesWelcomeWithTheApp() {
        let login = install(account: nil)
        let app = AppCoordinator(launch: .mainApp)
        app.start()
        let welcome = app.rootViewController.current

        login.finish()

        // Welcome fades out and leaves once the animation ends.
        #expect(app.rootViewController.current !== welcome)
        #expect(!(app.rootViewController.current is UINavigationController))
    }

    private func install(account: Account?) -> FakeLoginEntryPoint {
        let container = DependencyInjectionContainer.testScoped
        let login = FakeLoginEntryPoint()
        container.register(.eager(FakeAuthenticationService(currentAccount: account)), for: AuthenticationService.self)
        container.register(.eager(login), for: LoginEntryPoint.self)
        return login
    }
}

private final class FakeLoginEntryPoint: LoginEntryPoint {
    private(set) var coordinators: [FakeCoordinator] = []
    private var onLoggedIn: (@MainActor () -> Void)?

    func attach(
        to navigationController: UINavigationController,
        onLoggedIn: @escaping @MainActor () -> Void
    ) -> Coordinator {
        self.onLoggedIn = onLoggedIn
        let coordinator = FakeCoordinator(navigationController: navigationController)
        coordinators.append(coordinator)
        return coordinator
    }

    func finish() {
        onLoggedIn?()
    }
}

private final class FakeCoordinator: Coordinator {
    let navigationController: UINavigationController
    private(set) var started = false

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        started = true
    }
}

private final class FakeAuthenticationService: AuthenticationService {
    let currentAccount: Account?

    init(currentAccount: Account?) {
        self.currentAccount = currentAccount
    }

    func signInWithApple() async throws(AuthenticationError) -> Account {
        throw .failed
    }

    func continueAsGuest() async throws(AuthenticationError) -> Account {
        throw .failed
    }

    func authorized<Value, Failure: Error>(
        _: (_ accessToken: String) async throws(Failure) -> Value,
        isUnauthorized _: (Failure) -> Bool
    ) async throws(AuthorizedCallError<Failure>) -> Value {
        throw .signedOut
    }
}
