import Account
import AppleSignInInterface
import BackgroundTaskInterface
import DependencyInjection
import DependencyInjectionTestSupport
import DeviceIDInterface
import Foundation
import Session
import SessionResourceInterface
import SessionStorageInterface

/// The fakes `Fakes.install` registers, for a test to set up and inspect.
struct Fakes {
    let resource: FakeSessionResource
    let storage: FakeSessionStorage
    let background: FakeBackgroundTaskRunner

    /// Registers fakes for everything `AuthenticationServiceImpl` depends on.
    @discardableResult
    static func install(
        resource result: Result<Session, SessionResourceError>,
        apple: Result<AppleIDCredential, AppleSignInError> = .failure(.failed),
        refresh: [Result<Session, SessionResourceError>] = [],
        suspendsRefresh: Bool = false
    ) -> Fakes {
        let container = DependencyInjectionContainer.testScoped
        let fakes = Fakes(
            resource: FakeSessionResource(result: result, refreshResults: refresh, suspendsRefresh: suspendsRefresh),
            storage: FakeSessionStorage(),
            background: FakeBackgroundTaskRunner()
        )
        container.register(.eager(fakes.resource), for: SessionResource.self)
        container.register(.eager(fakes.storage), for: SessionStorage.self)
        container.register(.eager(FakeDeviceIDProvider()), for: DeviceIDProvider.self)
        container.register(.eager(FakeAppleSignInClient(result: apple)), for: AppleSignInClient.self)
        container.register(.eager(fakes.background), for: BackgroundTaskRunner.self)
        return fakes
    }
}

nonisolated func session(_ suffix: String, expiresIn seconds: TimeInterval) -> Session {
    Session(
        accessToken: "t\(suffix)",
        refreshToken: "r\(suffix)",
        expiresAt: Date(timeIntervalSince1970: 1_800_000_000).addingTimeInterval(seconds),
        account: Account(id: .init(rawValue: "a1"), kind: .guest)
    )
}

/// An API call made through `authorized`: answers in turn and records the access tokens it got.
final class FakeAPI {
    enum Failure: Error, Equatable {
        case unauthorized
        case notFound
    }

    static func isUnauthorized(_ failure: Failure) -> Bool {
        failure == .unauthorized
    }

    private var answers: [Result<String, Failure>]
    private(set) var tokens: [String] = []
    /// Runs once, during the first call.
    var onCall: (() -> Void)?

    init(answers: [Result<String, Failure>] = [.success("ok")]) {
        self.answers = answers
    }

    func call(_ accessToken: String) async throws(Failure) -> String {
        tokens.append(accessToken)
        onCall?()
        onCall = nil
        return try answers.removeFirst().get()
    }
}

final class FakeSessionResource: SessionResource {
    enum Call: Equatable {
        case guest(deviceID: String)
        case apple(AppleSessionCredentials)
        case refresh(refreshToken: String)
    }

    let result: Result<Session, SessionResourceError>
    private var refreshResults: [Result<Session, SessionResourceError>]
    private let suspendsRefresh: Bool
    private(set) var calls: [Call] = []
    /// Runs inside every refresh.
    var duringRefresh: (() -> Void)?
    private var refreshCalled: CheckedContinuation<Void, Never>?
    private var refreshGate: CheckedContinuation<Void, Never>?

    init(
        result: Result<Session, SessionResourceError>,
        refreshResults: [Result<Session, SessionResourceError>] = [],
        suspendsRefresh: Bool = false
    ) {
        self.result = result
        self.refreshResults = refreshResults
        self.suspendsRefresh = suspendsRefresh
    }

    func refreshSession(refreshToken: String) async throws(SessionResourceError) -> Session {
        calls.append(.refresh(refreshToken: refreshToken))
        duringRefresh?()
        refreshCalled?.resume()
        refreshCalled = nil
        if suspendsRefresh {
            await withCheckedContinuation { refreshGate = $0 }
        }
        // The last result answers every refresh after it.
        return try (refreshResults.count > 1 ? refreshResults.removeFirst() : refreshResults[0]).get()
    }

    /// Returns once a refresh has started.
    func waitForRefresh() async {
        guard !calls.contains(where: {
            if case .refresh = $0 {
                true
            } else {
                false
            }
        }) else {
            return
        }
        await withCheckedContinuation { refreshCalled = $0 }
    }

    func resumeRefresh() {
        refreshGate?.resume()
        refreshGate = nil
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

final class FakeSessionStorage: SessionStorage {
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

/// Records the retry delays instead of waiting them out.
final class FakeSleeper {
    private(set) var delays: [Duration] = []
    /// Makes every wait throw, as a cancelled one does.
    var fails = false

    var sleep: @Sendable (Duration) async throws -> Void {
        { delay in try await self.record(delay) }
    }

    private func record(_ delay: Duration) throws {
        delays.append(delay)
        if fails {
            throw CancellationError()
        }
    }
}

/// Runs the work right away and records it.
final class FakeBackgroundTaskRunner: BackgroundTaskRunner {
    private(set) var names: [String] = []
    private(set) var running = false

    func run<Value>(named name: String, _ work: () async -> Value) async -> Value {
        names.append(name)
        running = true
        defer { running = false }
        return await work()
    }
}
