import Account
import AppleSignInInterface
import AuthenticationInterface
import DependencyInjection
import DeviceIDInterface
import Foundation
import Session
import SessionResourceInterface
import SessionStorageInterface

final class AuthenticationServiceImpl: AuthenticationService {
    /// How long before `expiresAt` a session is refreshed, so a request doesn't arrive with a token
    /// that expired on the way.
    static let refreshLeeway: TimeInterval = 60

    @Dependency private var sessions: SessionResource
    @Dependency private var storage: SessionStorage
    @Dependency private var device: DeviceIDProvider
    @Dependency private var appleSignIn: AppleSignInClient

    private let now: () -> Date
    private let refresher: SessionRefresher

    init(now: @escaping () -> Date = Date.init, refresher: SessionRefresher = SessionRefresher()) {
        self.now = now
        self.refresher = refresher
    }

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

    func authorized<Value, Failure: Error>(
        _ call: (_ accessToken: String) async throws(Failure) -> Value,
        isUnauthorized: (Failure) -> Bool
    ) async throws(AuthorizedCallError<Failure>) -> Value {
        guard var session = storage.session else {
            throw .signedOut
        }
        if session.expiresAt.timeIntervalSince(now()) < Self.refreshLeeway {
            do throws(RefreshFailure) {
                session = try await refresher.session(replacing: session)
            } catch {
                throw AuthorizedCallError(error)
            }
        }
        do throws(Failure) {
            return try await call(session.accessToken)
        } catch {
            guard isUnauthorized(error) else {
                throw .call(error)
            }
        }
        do throws(RefreshFailure) {
            session = try await refresher.session(replacing: session)
        } catch {
            throw AuthorizedCallError(error)
        }
        do throws(Failure) {
            return try await call(session.accessToken)
        } catch {
            throw .call(error)
        }
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

private extension AuthorizedCallError {
    init(_ failure: RefreshFailure) {
        switch failure {
        case .signedOut: self = .signedOut
        case .offline: self = .offline
        case .failed: self = .failed
        }
    }
}
