import Session

public struct SessionStorageError: Error, Equatable, Sendable {
    public init() {}
}

/// The session on this device, kept across launches.
public protocol SessionStorage {
    /// The stored session, or nil before the first sign-in.
    var session: Session? { get }
    /// Stores `session`, or removes it when nil.
    func store(_ session: Session?) throws(SessionStorageError)
}
