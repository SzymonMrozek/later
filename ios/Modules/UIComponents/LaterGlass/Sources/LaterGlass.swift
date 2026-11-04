import LaterColor
import LaterShadow
import LaterStroke
import SwiftUI

public extension View {
    /// Liquid Glass behind the view, clipped to `shape`: the system material on iOS 26 and later,
    /// and the canvas's translucent `color.glass.*` fill, edge and shadow before that.
    func laterGlass(in shape: some Shape, isInteractive: Bool = false) -> some View {
        modifier(LaterGlassModifier(shape: shape, isInteractive: isInteractive))
    }
}

private struct LaterGlassModifier<GlassShape: Shape>: ViewModifier {
    let shape: GlassShape
    let isInteractive: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(isInteractive), in: shape)
        } else {
            content
                .background(LaterColor.Glass.base, in: shape)
                .overlay(shape.stroke(LaterColor.Glass.stroke, lineWidth: LaterStroke.default))
                .laterShadow(.glass)
        }
    }
}
