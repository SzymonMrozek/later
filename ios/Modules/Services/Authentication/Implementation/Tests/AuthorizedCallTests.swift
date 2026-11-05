import Account
@testable import AuthenticationImplementation
import AuthenticationInterface
import BackgroundTaskInterface
import DependencyInjection
import DependencyInjectionTestSupport
import Foundation
import Session
import SessionResourceInterface
import SessionStorageInterface
import Testing

/// `AuthenticationServiceImpl.authorized` and the `SessionRefresher` behind it.
@Suite(.dependencyContainer)
struct AuthorizedCallTests {
    static let now = Date(timeIntervalSince1970: 1_800_000_000)
    private let guest = session("1", expiresIn: 3600)
    private let refreshed = session("3", expiresIn: 3600)
    private let sleeper = FakeSleeper()

    @Test func callsWithTheStoredAccessToken() async throws {
        let fakes = Fakes.install(resource: .failure(.unreachable))
        fakes.storage.session = guest
        let api = FakeAPI()

        let value = try await service().authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized)

        #expect(value == "ok")
        #expect(api.tokens == ["t1"])
        #expect(fakes.resource.calls.isEmpty)
    }

    @Test func refreshesASessionThatExpiresWithinAMinute() async throws {
        let fakes = Fakes.install(resource: .failure(.unreachable), refresh: [.success(refreshed)])
        fakes.storage.session = session("1", expiresIn: 59)
        let api = FakeAPI()

        _ = try await service().authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized)

        #expect(fakes.resource.calls == [.refresh(refreshToken: "r1")])
        #expect(api.tokens == ["t3"])
        #expect(fakes.storage.session == refreshed)
    }

    @Test func refreshesOnceAfterA401AndCallsAgain() async throws {
        let fakes = Fakes.install(resource: .failure(.unreachable), refresh: [.success(refreshed)])
        fakes.storage.session = guest
        let api = FakeAPI(answers: [.failure(.unauthorized), .success("ok")])

        let value = try await service().authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized)

        #expect(value == "ok")
        #expect(api.tokens == ["t1", "t3"])
        #expect(fakes.resource.calls == [.refresh(refreshToken: "r1")])
        #expect(fakes.storage.session == refreshed)
    }

    @Test func aSecond401IsTheCallsFailure() async {
        let fakes = Fakes.install(resource: .failure(.unreachable), refresh: [.success(refreshed)])
        fakes.storage.session = guest
        let api = FakeAPI(answers: [.failure(.unauthorized), .failure(.unauthorized)])

        await #expect(throws: AuthorizedCallError.call(FakeAPI.Failure.unauthorized)) {
            try await service().authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized)
        }
        #expect(api.tokens == ["t1", "t3"])
        #expect(fakes.resource.calls.count == 1)
    }

    @Test func anotherFailureIsTheCallsWithoutARefresh() async {
        let fakes = Fakes.install(resource: .failure(.unreachable))
        fakes.storage.session = guest
        let api = FakeAPI(answers: [.failure(.notFound)])

        await #expect(throws: AuthorizedCallError.call(FakeAPI.Failure.notFound)) {
            try await service().authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized)
        }
        #expect(fakes.resource.calls.isEmpty)
    }

    @Test func signsOutWhenTheAPIRefusesTheRefreshToken() async {
        let fakes = Fakes.install(resource: .failure(.unreachable), refresh: [.failure(.rejected)])
        fakes.storage.session = guest
        let api = FakeAPI(answers: [.failure(.unauthorized)])
        let service = service()

        await #expect(throws: AuthorizedCallError<FakeAPI.Failure>.signedOut) {
            try await service.authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized)
        }
        #expect(fakes.storage.session == nil)
        #expect(service.currentAccount == nil)
        #expect(api.tokens == ["t1"])
    }

    @Test(arguments: [
        (SessionResourceError.unreachable, AuthorizedCallError<FakeAPI.Failure>.offline),
        (.invalidResponse, .failed),
    ])
    func keepsTheSessionWhenARefreshCantFinishAfterRetries(
        _ error: SessionResourceError,
        _ expected: AuthorizedCallError<FakeAPI.Failure>
    ) async {
        let expiring = session("1", expiresIn: 0)
        let fakes = Fakes.install(resource: .failure(.unreachable), refresh: [.failure(error)])
        fakes.storage.session = expiring
        let api = FakeAPI()

        await #expect(throws: expected) {
            try await service().authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized)
        }
        #expect(fakes.storage.session == expiring)
        #expect(api.tokens.isEmpty)
        #expect(fakes.resource.calls.count == 4)
        #expect(sleeper.delays == SessionRefresher.retryDelays)
    }

    @Test func retriesARefreshUntilItFinishes() async throws {
        let fakes = Fakes.install(
            resource: .failure(.unreachable),
            refresh: [.failure(.unreachable), .failure(.invalidResponse), .success(refreshed)]
        )
        fakes.storage.session = session("1", expiresIn: 0)
        let api = FakeAPI()

        _ = try await service().authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized)

        #expect(fakes.resource.calls.count == 3)
        #expect(sleeper.delays == [.milliseconds(500), .seconds(2)])
        #expect(api.tokens == ["t3"])
        #expect(fakes.storage.session == refreshed)
    }

    @Test func aRejectedRefreshIsNotRetried() async {
        let fakes = Fakes.install(resource: .failure(.unreachable), refresh: [.failure(.rejected), .success(refreshed)])
        fakes.storage.session = session("1", expiresIn: 0)

        await #expect(throws: AuthorizedCallError<FakeAPI.Failure>.signedOut) {
            try await service().authorized(FakeAPI().call, isUnauthorized: FakeAPI.isUnauthorized)
        }
        #expect(fakes.resource.calls.count == 1)
        #expect(sleeper.delays.isEmpty)
    }

    @Test func aCancelledWaitStopsRetrying() async {
        let fakes = Fakes.install(
            resource: .failure(.unreachable),
            refresh: [.failure(.unreachable), .success(refreshed)]
        )
        fakes.storage.session = session("1", expiresIn: 0)
        sleeper.fails = true

        await #expect(throws: AuthorizedCallError<FakeAPI.Failure>.offline) {
            try await service().authorized(FakeAPI().call, isUnauthorized: FakeAPI.isUnauthorized)
        }
        #expect(fakes.resource.calls.count == 1)
    }

    @Test func refreshesInsideABackgroundTask() async throws {
        let fakes = Fakes.install(resource: .failure(.unreachable), refresh: [.success(refreshed)])
        fakes.storage.session = session("1", expiresIn: 0)
        var refreshedInBackground = false
        fakes.resource.duringRefresh = { refreshedInBackground = fakes.background.running }

        _ = try await service().authorized(FakeAPI().call, isUnauthorized: FakeAPI.isUnauthorized)

        #expect(refreshedInBackground)
        #expect(fakes.background.names == ["Session refresh"])
        #expect(!fakes.background.running)
    }

    @Test func isSignedOutWithoutASession() async {
        let fakes = Fakes.install(resource: .failure(.unreachable))
        let api = FakeAPI()

        await #expect(throws: AuthorizedCallError<FakeAPI.Failure>.signedOut) {
            try await service().authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized)
        }
        #expect(api.tokens.isEmpty)
        #expect(fakes.resource.calls.isEmpty)
    }

    @Test func callsAtTheSameTimeShareOneRefresh() async throws {
        let fakes = Fakes.install(
            resource: .failure(.unreachable),
            refresh: [.success(refreshed)],
            suspendsRefresh: true
        )
        fakes.storage.session = session("1", expiresIn: 0)
        let service = service()
        let api = FakeAPI(answers: [.success("a"), .success("b")])

        let first = Task { try await service.authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized) }
        await fakes.resource.waitForRefresh()
        let second = Task { try await service.authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized) }
        // Lets the second call reach the refresh the first one started.
        await Task.yield()
        fakes.resource.resumeRefresh()

        #expect(try await [first.value, second.value].sorted() == ["a", "b"])
        #expect(fakes.resource.calls == [.refresh(refreshToken: "r1")])
        #expect(api.tokens == ["t3", "t3"])
    }

    @Test func usesTheSessionAnotherCallAlreadyRefreshed() async throws {
        let fakes = Fakes.install(resource: .failure(.unreachable))
        fakes.storage.session = guest
        let api = FakeAPI(answers: [.failure(.unauthorized), .success("ok")])
        // Another call refreshes the session while this one waits for its 401.
        api.onCall = { fakes.storage.session = refreshed }

        _ = try await service().authorized(api.call, isUnauthorized: FakeAPI.isUnauthorized)

        #expect(fakes.resource.calls.isEmpty)
        #expect(api.tokens == ["t1", "t3"])
    }

    private func service() -> AuthenticationServiceImpl {
        AuthenticationServiceImpl(now: { Self.now }, refresher: SessionRefresher(sleep: sleeper.sleep))
    }
}
