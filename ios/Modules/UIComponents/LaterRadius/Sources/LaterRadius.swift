import CoreGraphics

/// The `radius.*` tokens from design/Later.canvas, in points.
public enum LaterRadius {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 9
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let sheet: CGFloat = 26
    /// Fully rounded ends. Prefer `Capsule()` where a shape is needed.
    public static let pill: CGFloat = 999
}
