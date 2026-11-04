import LaterColor
import LaterSize
import LaterSpacing
import SwiftUI

/// `StepIndicator` from design/Later.canvas: dots for the first-run steps, the current one wide.
public struct LaterStepIndicator: View {
    private let count: Int
    private let current: Int

    /// - Parameters:
    ///   - current: The current step, from 0.
    public init(count: Int, current: Int) {
        self.count = count
        self.current = current
    }

    public var body: some View {
        HStack(spacing: LaterSpacing.one) {
            ForEach(0 ..< count, id: \.self) { step in
                Capsule()
                    .fill(step == current ? LaterColor.Accent.base : LaterColor.Control.fillPlaceholder)
                    .frame(width: step == current ? LaterSize.dotActive : LaterSize.dot, height: LaterSize.dot)
            }
        }
        .animation(.snappy, value: current)
        .accessibilityElement()
        .accessibilityLabel(Text("Step \(current + 1) of \(count)"))
    }
}
