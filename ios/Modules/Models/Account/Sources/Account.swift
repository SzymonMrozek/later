/// The person using Later on this device: a guest until they sign in, then their Apple account.
public nonisolated struct Account: Equatable, Identifiable, Sendable {
    public struct ID: RawRepresentable, Hashable, Sendable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    public enum Kind: Equatable, Sendable {
        /// Created for this device without signing in. Signing in later keeps the library.
        case guest
        /// Signed in with Apple; `email` is nil when the person didn't share it.
        case apple(email: String?)
    }

    public let id: ID
    public let kind: Kind

    public init(id: ID, kind: Kind) {
        self.id = id
        self.kind = kind
    }

    public var isGuest: Bool {
        kind == .guest
    }
}
