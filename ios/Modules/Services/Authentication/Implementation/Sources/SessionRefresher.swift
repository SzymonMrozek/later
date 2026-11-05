import BackgroundTaskInterface
import DependencyInjection
import Session
import SessionResourceInterface
import SessionStorageInterface

/// Trades the stored session for the next one, one refresh at a time: a refresh token works only
/// once, so callers that need a refresh while one runs wait for it instead of starting another.
final class SessionRefresher {
    /// How long to wait before each retry of a refresh that couldn't finish.
    static let retryDelays: [Duration] = [.milliseconds(500), .seconds(2), .seconds(10)]

    @Dependency private var sessions: SessionResource
    @Dependency private var storage: SessionStorage
    @Dependency private var background: BackgroundTaskRunner

    private let retryDelays: [Duration]
    private let sleep: @Sendable (Duration) async throws -> Void
    private var refreshing: Task<Result<Session, RefreshFailure>, Never>?

    init(
        retryDelays: [Duration] = SessionRefresher.retryDelays,
        sleep: @escaping @Sendable (Duration) async throws -> Void = {
            // Jitter keeps devices that lost the network together from retrying together.
            try await Task.sleep(for: $0 * Double.random(in: 0.8 ... 1.2))
        }
    ) {
        self.retryDelays = retryDelays
        self.sleep = sleep
    }

    /// The session that replaces `stale`: the stored one when another call already refreshed it,
    /// the result of the refresh in flight, or a new one from the API.
    func session(replacing stale: Session) async throws(RefreshFailure) -> Session {
        guard let stored = storage.session else {
            throw .signedOut
        }
        if stored.refreshToken != stale.refreshToken {
            return stored
        }
        let refresh = refreshing ?? Task { await self.refreshWithRetries(stored) }
        refreshing = refresh
        let result = await refresh.value
        if refreshing == refresh {
            refreshing = nil
        }
        return try result.get()
    }

    /// Retries a refresh the API couldn't answer, and stops at once when it refuses the refresh
    /// token. Runs as a background task: the API may already have rotated the token, so the app
    /// keeps running until the new session is stored.
    private func refreshWithRetries(_ session: Session) async -> Result<Session, RefreshFailure> {
        await background.run(named: "Session refresh") {
            var delays = retryDelays[...]
            while true {
                let failure: RefreshFailure
                do throws(SessionResourceError) {
                    return try await store(sessions.refreshSession(refreshToken: session.refreshToken))
                } catch {
                    switch error {
                    case .rejected:
                        signOut(session)
                        return .failure(.signedOut)
                    case .unreachable: failure = .offline
                    case .invalidResponse: failure = .failed
                    }
                }
                guard let delay = delays.popFirst() else {
                    return .failure(failure)
                }
                do {
                    try await sleep(delay)
                } catch {
                    return .failure(failure)
                }
            }
        }
    }

    private func store(_ next: Session) -> Result<Session, RefreshFailure> {
        do throws(SessionStorageError) {
            try storage.store(next)
        } catch {
            return .failure(.failed)
        }
        return .success(next)
    }

    /// The refresh token is no good, so this session can't continue. A sign-in that replaced it
    /// meanwhile stays.
    private func signOut(_ session: Session) {
        if storage.session?.refreshToken == session.refreshToken {
            try? storage.store(nil)
        }
    }
}

enum RefreshFailure: Error {
    /// Nobody is signed in, or the API refused the refresh token.
    case signedOut
    /// The API couldn't be reached, on every attempt.
    case offline
    /// The API answered with something unexpected, or the new session couldn't be stored.
    case failed
}
