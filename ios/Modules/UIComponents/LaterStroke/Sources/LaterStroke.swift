import CoreGraphics

/// The `stroke.*` tokens from design/Later.canvas: border widths in points.
public enum LaterStroke {
    public static let `default`: CGFloat = 1
    public static let selected: CGFloat = 1.5
    /// The dash of `color.control.lineDashed` borders.
    public static let dash: [CGFloat] = [4, 3]
}
