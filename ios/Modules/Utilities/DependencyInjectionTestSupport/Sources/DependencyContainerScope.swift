import DependencyInjection
import Testing

/// Runs every test case with its own `DependencyInjectionContainer`.
///
/// `@Dependency` resolves on first read, so the container stays installed for the whole test, not
/// only while the subject is created. Register stubs on `DependencyInjectionContainer.testScoped`.
public nonisolated struct DependencyContainerScope: SuiteTrait, TestTrait, TestScoping {
    @TaskLocal fileprivate static var current: DependencyInjectionContainer?

    public var isRecursive: Bool {
        true
    }

    public func provideScope(
        for _: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        guard testCase != nil else {
            try await function()
            return
        }
        let container = DependencyInjectionContainer()
        try await Self.$current.withValue(container) {
            try await DependencyInjectionContainer.$shared.withValue(container) {
                try await function()
            }
        }
    }
}

public extension Trait where Self == DependencyContainerScope {
    /// Installs a fresh dependency container for each test case.
    static var dependencyContainer: Self {
        DependencyContainerScope()
    }
}

public extension DependencyInjectionContainer {
    /// The container the `.dependencyContainer` trait installed for the running test case.
    nonisolated static var testScoped: DependencyInjectionContainer {
        guard let container = DependencyContainerScope.current else {
            preconditionFailure("Add the .dependencyContainer trait to the test or its suite.")
        }
        return container
    }
}
