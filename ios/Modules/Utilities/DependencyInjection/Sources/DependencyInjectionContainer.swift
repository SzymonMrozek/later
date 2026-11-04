import Foundation

/// Binds each contract to the implementation the app selected. Implementation modules register
/// their own bindings in `register()`; the composition root calls those, and consumers resolve
/// contracts with `@Dependency`.
///
/// Registration and resolution happen on the main actor. Tests install a container of their own
/// for one test with `DependencyInjectionContainer.$shared.withValue(_:operation:)`, or through the
/// `.dependencyContainer` trait in DependencyInjectionTestSupport.
public final nonisolated class DependencyInjectionContainer: @unchecked Sendable {
    @TaskLocal public static var shared = DependencyInjectionContainer()

    /// How a registration produces its value.
    public struct Registration<Value> {
        let kind: RegistrationKind<Value>

        /// Built on first use, then shared. The default.
        public static func lazy(_ make: @escaping @MainActor () -> Value) -> Self {
            Self(kind: .lazy(make))
        }

        /// A value built now, such as a stub installed by a test.
        public static func eager(_ value: Value) -> Self {
            Self(kind: .eager(value))
        }

        /// Built again on every resolution.
        public static func volatile(_ make: @escaping @MainActor () -> Value) -> Self {
            Self(kind: .volatile(make))
        }
    }

    private enum Entry {
        case factory(@MainActor () -> Any, shared: Bool)
        case instance(Any)
    }

    private let lock = NSLock()
    private var entries: [ObjectIdentifier: Entry] = [:]

    public init() {}

    /// Binds `type` to `registration`, replacing an earlier binding.
    public func register<Value>(_ registration: Registration<Value>, for type: Value.Type) {
        let entry: Entry = switch registration.kind {
        case let .lazy(make): .factory(make, shared: true)
        case let .eager(value): .instance(value)
        case let .volatile(make): .factory(make, shared: false)
        }
        lock.withLock { entries[ObjectIdentifier(type)] = entry }
    }

    /// The value bound to `type`. Resolving a contract nobody registered is a programming error.
    @MainActor public func resolve<Value>(_ type: Value.Type = Value.self) -> Value {
        let key = ObjectIdentifier(type)
        guard let entry = lock.withLock({ entries[key] }) else {
            preconditionFailure("Nothing is registered for \(type). Register it in its module's register().")
        }
        switch entry {
        case let .instance(value):
            return cast(value, to: type)
        case let .factory(make, shared):
            let value = cast(make(), to: type)
            if shared {
                lock.withLock { entries[key] = .instance(value) }
            }
            return value
        }
    }

    private func cast<Value>(_ value: Any, to type: Value.Type) -> Value {
        guard let value = value as? Value else {
            preconditionFailure("The registration for \(type) produced \(Swift.type(of: value)).")
        }
        return value
    }
}

nonisolated enum RegistrationKind<Value> {
    case lazy(@MainActor () -> Value)
    case eager(Value)
    case volatile(@MainActor () -> Value)
}
