import Foundation

public struct KeychainError: Error, Equatable, Sendable {
    /// The Security framework's `OSStatus`.
    public let status: Int32

    public init(status: Int32) {
        self.status = status
    }
}

/// Small secrets on this device, such as a session token, kept across launches and reinstalls.
public protocol Keychain: Sendable {
    func data(for key: String) -> Data?
    /// Stores `data` under `key`, or removes the item when `data` is nil.
    func set(_ data: Data?, for key: String) throws(KeychainError)
}
