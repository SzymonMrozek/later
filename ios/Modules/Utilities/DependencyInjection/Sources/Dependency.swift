/// Resolves a contract from `DependencyInjectionContainer.shared` the first time it's read.
///
/// A dependency one function reads is a local `@Dependency var` in that function; one that several
/// members read is a stored property.
@propertyWrapper
public final class Dependency<Value> {
    private var value: Value?

    public nonisolated init() {}

    public var wrappedValue: Value {
        if let value {
            return value
        }
        let resolved = DependencyInjectionContainer.shared.resolve(Value.self)
        value = resolved
        return resolved
    }
}
