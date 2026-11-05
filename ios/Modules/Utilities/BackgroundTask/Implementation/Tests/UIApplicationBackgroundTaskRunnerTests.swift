@testable import BackgroundTaskImplementation
import Testing
import UIKit

struct UIApplicationBackgroundTaskRunnerTests {
    @Test func endsTheTaskOnceTheWorkFinishes() async {
        let system = FakeSystem()

        let value = await system.runner.run(named: "Work") {
            #expect(system.begun == ["Work"])
            #expect(system.ended.isEmpty)
            return 42
        }

        #expect(value == 42)
        #expect(system.ended == [UIBackgroundTaskIdentifier(rawValue: 7)])
    }

    @Test func endsTheTaskOnceWhenTheSystemRunsOutOfTime() async {
        let system = FakeSystem()

        await system.runner.run(named: "Work") {
            system.expire()
            #expect(system.ended == [UIBackgroundTaskIdentifier(rawValue: 7)])
        }

        #expect(system.ended == [UIBackgroundTaskIdentifier(rawValue: 7)])
    }

    @Test func runsTheWorkWhenTheSystemGivesNoTime() async {
        let system = FakeSystem(identifier: .invalid)

        let value = await system.runner.run(named: "Work") { "done" }

        #expect(value == "done")
        #expect(system.ended.isEmpty)
    }
}

/// Stands in for `UIApplication`: hands out `identifier` and records what began and ended.
private final class FakeSystem {
    private(set) var begun: [String] = []
    private(set) var ended: [UIBackgroundTaskIdentifier] = []
    private var expiration: (@MainActor @Sendable () -> Void)?
    private let identifier: UIBackgroundTaskIdentifier

    init(identifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 7)) {
        self.identifier = identifier
    }

    var runner: UIApplicationBackgroundTaskRunner {
        UIApplicationBackgroundTaskRunner(
            begin: { name, expiration in
                self.begun.append(name)
                self.expiration = expiration
                return self.identifier
            },
            end: { self.ended.append($0) }
        )
    }

    func expire() {
        expiration?()
    }
}
