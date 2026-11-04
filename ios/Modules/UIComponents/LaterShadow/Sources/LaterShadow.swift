import LaterColor
import SwiftUI

/// The `shadow.*` tokens from design/Later.canvas, each with its `color.overlay.shadow*` color.
public struct LaterShadow: Sendable {
    public let color: Color
    public let radius: CGFloat
    public let y: CGFloat

    /// The selected segment of a segmented control.
    public static let control = LaterShadow(color: LaterColor.Overlay.shadowControl, radius: 1, y: 1)
    /// Sheets and menus floating over content.
    public static let float = LaterShadow(color: LaterColor.Overlay.shadowFloat, radius: 12, y: 8)
    /// Liquid Glass controls drawn without the system material.
    public static let glass = LaterShadow(color: LaterColor.Overlay.shadowGlass, radius: 10, y: 4)
}

public extension View {
    func laterShadow(_ shadow: LaterShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
    }
}
