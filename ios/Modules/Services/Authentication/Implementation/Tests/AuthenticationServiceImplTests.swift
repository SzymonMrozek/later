import Account
import AppleSignInInterface
@testable import AuthenticationImplementation
import AuthenticationInterface
import DependencyInjection
import DependencyInjectionTestSupport
import DeviceIDInterface
import Session
import SessionResourceInterface
import SessionStorageInterface
import Testing

@Suite(.dependencyContainer)
struct AuthenticationServiceImplTests {
    private let guest = Session(token: "t1", account: Account(id: .init(rawValue: "a1"), kind: .guest))
    private let apple = Session(
        token: "t2",
        account: Account(id: .init(rawValue: "a1"), kind: .apple(email: "me@example.com"))
    )
    private let credential = AppleIDCredential(
        identityToken: "jwt",
        authorizationCode: "code",
        givenName: "Ada",
        familyName: "Lovelace",
        email: "me@example.com"
    )

    @Test func continuesAsGuestAndKeepsTheSession() async throws {
        let fakes = install(resource: .success(guest))
        let service = AuthenticationServiceImpl()

        let account = try await service.continueAsGuest()

        #expect(account == guest.account)
        #expect(fakes.resource.calls == [.guest(deviceID: "device-1")])
        #expect(fakes.storage.session == guest)
        #expect(service.currentAccount == guest.account)
    }

    @Test func signsInWithAppleSendingTheCredentialAndDeviceID() async throws {
        let fakes = install(resource: .success(apple), apple: .success(credential))

        let account = try await AuthenticationServiceImpl().signInWithApple()

        #expect(account == apple.account)
        let sent = AppleSessionCredentials(
            deviceID: "device-1",
            identityToken: "jwt",
            authorizationCode: "code",
            givenName: "Ada",
            familyName: "Lovelace",
            email: "me@example.com"
        )
        #expect(fakes.resource.calls == [.apple(sent)])
        #expect(fakes.storage.session == apple)
    }

    @Test func readsTheAccountFromStorage() {
        let fakes = install(resource: .failure(.unreachable))
        #expect(AuthenticationServiceImpl().currentAccount == nil)

        fakes.storage.session = guest

        #expect(AuthenticationServiceImpl().currentAccount == guest.account)
    }

    @Test func closingApplesSheetIsACancellationWithoutARequest() async {
        let fakes = install(resource: .success(apple), apple: .failure(.cancelled))

        await #expect(throws: AuthenticationError.cancelled) { try await AuthenticationServiceImpl().signInWithApple() }
        #expect(fakes.resource.calls.isEmpty)
        #expect(fakes.storage.session == nil)
    }

    @Test func anAppleFailureFails() async {
        install(resource: .success(apple), apple: .failure(.failed))
        await #expect(throws: AuthenticationError.failed) { try await AuthenticationServiceImpl().signInWithApple() }
    }

    @Test(arguments: [
        (SessionResourceError.unreachable, AuthenticationError.offline),
        (.rejected, .failed),
        (.invalidResponse, .failed),
    ])
    func mapsResourceErrors(_ error: SessionResourceError, to expected: AuthenticationError) async {
        let fakes = install(resource: .failure(error))

        await #expect(throws: expected) { try await AuthenticationServiceImpl().continueAsGuest() }
        #expect(fakes.storage.session == nil)
    }

    @Test func aSessionThatCantBeStoredFails() async {
        let fakes = install(resource: .success(guest))
        fakes.storage.fails = true

        await #expect(throws: AuthenticationError.failed) { try await AuthenticationServiceImpl().continueAsGuest() }
    }

    @discardableResult
    private func install(
        resource result: Result<Session, SessionResourceError>,
        apple: Result<AppleIDCredential, AppleSignInError> = .failure(.failed)
    ) -> (resource: FakeSessionResource, storage: FakeSessionStorage) {
        let container = DependencyInjectionContainer.testScoped
        let resource = FakeSessionResource(result: result)
        let storage = FakeSessionStorage()
        container.register(.eager(resource), for: SessionResource.self)
        container.register(.eager(storage), for: SessionStorage.self)
        container.register(.eager(FakeDeviceIDProvider()), for: DeviceIDProvider.self)
        container.register(.eager(FakeAppleSignInClient(result: apple)), for: AppleSignInClient.self)
        return (resource, storage)
    }
}

private final class FakeSessionResource: SessionResource {
    enum Call: Equatable {
        case guest(deviceID: String)
        case apple(AppleSessionCredentials)
    }

    let result: Result<Session, SessionResourceError>
    private(set) var calls: [Call] = []

    init(result: Result<Session, SessionResourceError>) {
        self.result = result
    }

    func createGuestSession(deviceID: String) async throws(SessionResourceError) -> Session {
        calls.append(.guest(deviceID: deviceID))
        return try result.get()
    }

    func createAppleSession(_ credentials: AppleSessionCredentials) async throws(SessionResourceError) -> Session {
        calls.append(.apple(credentials))
        return try result.get()
    }
}

private final class FakeSessionStorage: SessionStorage {
    var session: Session?
    var fails = false

    func store(_ session: Session?) throws(SessionStorageError) {
        if fails {
            throw SessionStorageError()
        }
        self.session = session
    }
}

private struct FakeDeviceIDProvider: DeviceIDProvider {
    let deviceID = "device-1"
}

private final class FakeAppleSignInClient: AppleSignInClient {
    let result: Result<AppleIDCredential, AppleSignInError>

    init(result: Result<AppleIDCredential, AppleSignInError>) {
        self.result = result
    }

    func signIn() async throws(AppleSignInError) -> AppleIDCredential {
        try result.get()
    }
}
