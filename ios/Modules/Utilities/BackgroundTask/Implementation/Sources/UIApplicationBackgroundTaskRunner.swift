import BackgroundTaskInterface
import UIKit

/// Wraps work in a `UIApplication` background task.
struct UIApplicationBackgroundTaskRunner: BackgroundTaskRunner {
    var begin: (_ name: String, _ expiration: @escaping @MainActor @Sendable () -> Void)
        -> UIBackgroundTaskIdentifier = {
            UIApplication.shared.beginBackgroundTask(withName: $0, expirationHandler: $1)
        }

    var end: (UIBackgroundTaskIdentifier) -> Void = { UIApplication.shared.endBackgroundTask($0) }

    func run<Value>(named name: String, _ work: () async -> Value) async -> Value {
        let task = BackgroundTask(end: end)
        task.identifier = begin(name) { [weak task] in task?.end() }
        defer { task.end() }
        return await work()
    }
}

/// One background task, ended once: when the work finishes, or when the system runs out of time
/// for it, whichever comes first.
private final class BackgroundTask {
    var identifier: UIBackgroundTaskIdentifier = .invalid
    private let endTask: (UIBackgroundTaskIdentifier) -> Void

    init(end: @escaping (UIBackgroundTaskIdentifier) -> Void) {
        endTask = end
    }

    func end() {
        guard identifier != .invalid else {
            return
        }
        let ended = identifier
        identifier = .invalid
        endTask(ended)
    }
}
