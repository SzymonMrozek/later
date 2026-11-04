/// Identifies this install to the API, so a guest keeps their account across launches and a later
/// sign-in can take over its library.
public protocol DeviceIDProvider {
    /// The same value for the life of the install, created on first use.
    var deviceID: String { get }
}
