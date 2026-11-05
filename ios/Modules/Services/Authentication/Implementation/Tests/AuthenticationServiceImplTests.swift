import Account
import AppleSignInInterface
@testable import AuthenticationImplementation
import AuthenticationInterface
import DependencyInjection
import DependencyInjectionTestSupport
import DeviceIDInterface
import Foundation
import Session
import SessionResourceInterface
import SessionStorageInterface
import Testing

@Suite(.dependencyContainer)
struct AuthenticationServiceImplTests {
    private let guest = session("1", expiresIn: 3600)
    private let apple = Session(
        accessToken: "t2",
        refreshToken: "r2",
        expiresAt: Date(timeIntervalSince1970: 1_800_003_600),
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
        let fakes = Fakes.install(resource: .success(guest))
        let service = AuthenticationServiceImpl()

        let account = try await service.continueAsGuest()

        #expect(account == guest.account)
        #expect(fakes.resource.calls == [.guest(deviceID: "device-1")])
        #expect(fakes.storage.session == guest)
        #expect(service.currentAccount == guest.account)
    }

    @Test func signsInWithAppleSendingTheCredentialAndDeviceID() async throws {
        let fakes = Fakes.install(resource: .success(apple), apple: .success(credential))

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
        let fakes = Fakes.install(resource: .failure(.unreachable))
        #expect(AuthenticationServiceImpl().currentAccount == nil)

        fakes.storage.session = guest

        #expect(AuthenticationServiceImpl().currentAccount == guest.account)
    }

    @Test func closingApplesSheetIsACancellationWithoutARequest() async {
        let fakes = Fakes.install(resource: .success(apple), apple: .failure(.cancelled))

        await #expect(throws: AuthenticationError.cancelled) { try await AuthenticationServiceImpl().signInWithApple() }
        #expect(fakes.resource.calls.isEmpty)
        #expect(fakes.storage.session == nil)
    }

    @Test func anAppleFailureFails() async {
        Fakes.install(resource: .success(apple), apple: .failure(.failed))
        await #expect(throws: AuthenticationError.failed) { try await AuthenticationServiceImpl().signInWithApple() }
    }

    @Test(arguments: [
        (SessionResourceError.unreachable, AuthenticationError.offline),
        (.rejected, .failed),
        (.invalidResponse, .failed),
    ])
    func mapsResourceErrors(_ error: SessionResourceError, to expected: AuthenticationError) async {
        let fakes = Fakes.install(resource: .failure(error))

        await #expect(throws: expected) { try await AuthenticationServiceImpl().continueAsGuest() }
        #expect(fakes.storage.session == nil)
    }

    @Test func aSessionThatCantBeStoredFails() async {
        let fakes = Fakes.install(resource: .success(guest))
        fakes.storage.fails = true

        await #expect(throws: AuthenticationError.failed) { try await AuthenticationServiceImpl().continueAsGuest() }
    }
}
