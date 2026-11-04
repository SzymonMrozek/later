import Account
import AppleSignInInterface
import AuthenticationInterface
import DependencyInjection
import DeviceIDInterface
import Session
import SessionResourceInterface
import SessionStorageInterface

final class AuthenticationServiceImpl: AuthenticationService {
    @Dependency private var sessions: SessionResource
    @Dependency private var storage: SessionStorage
    @Dependency private var device: DeviceIDProvider
    @Dependency private var appleSignIn: AppleSignInClient

    var currentAccount: Account? {
        storage.session?.account
    }

    func continueAsGuest() async throws(AuthenticationError) -> Account {
        let session: Session
        do throws(SessionResourceError) {
            session = try await sessions.createGuestSession(deviceID: device.deviceID)
        } catch {
            throw Self.authenticationError(error)
        }
        return try keep(session)
    }

    func signInWithApple() async throws(AuthenticationError) -> Account {
        let credential: AppleIDCredential
        do throws(AppleSignInError) {
            credential = try await appleSignIn.signIn()
        } catch {
            throw error == .cancelled ? .cancelled : .failed
        }
        let session: Session
        do throws(SessionResourceError) {
            session = try await sessions.createAppleSession(AppleSessionCredentials(
                deviceID: device.deviceID,
                identityToken: credential.identityToken,
                authorizationCode: credential.authorizationCode,
                givenName: credential.givenName,
                familyName: credential.familyName,
                email: credential.email
            ))
        } catch {
            throw Self.authenticationError(error)
        }
        return try keep(session)
    }

    /// Keeps the session on the device, so the account is there on the next launch.
    private func keep(_ session: Session) throws(AuthenticationError) -> Account {
        do throws(SessionStorageError) {
            try storage.store(session)
        } catch {
            throw .failed
        }
        return session.account
    }

    private static func authenticationError(_ error: SessionResourceError) -> AuthenticationError {
        error == .unreachable ? .offline : .failed
    }
}
