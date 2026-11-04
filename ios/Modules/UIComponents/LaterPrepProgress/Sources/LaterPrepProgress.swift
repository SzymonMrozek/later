import LaterColor
import LaterSpacing
import LaterTypography
import SwiftUI

/// `PrepProgress` from design/Later.canvas: the steps of preparing a saved article, done,
/// running and still to come.
public struct LaterPrepProgress: View {
    public enum StepState: Sendable {
        case done
        case running
        case pending
    }

    public struct Step: Hashable, Sendable {
        public let title: String
        public let state: StepState

        public init(_ title: String, state: StepState) {
            self.title = title
            self.state = state
        }
    }

    private let steps: [Step]

    public init(steps: [Step]) {
        self.steps = steps
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: LaterSpacing.three) {
            ForEach(steps, id: \.self) { step in
                HStack(spacing: LaterSpacing.two) {
                    icon(step.state)
                        .font(.laterUI(.bodyLarge, weight: .semibold))
                        .accessibilityHidden(true)
                    Text(step.title)
                        .font(.laterUI(.body, weight: step.state == .running ? .medium : .regular))
                        .foregroundStyle(step.state == .pending ? LaterColor.Text.inkMuted : LaterColor.Text.ink)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    @ViewBuilder private func icon(_ state: StepState) -> some View {
        switch state {
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(LaterColor.Status.positive)
        case .running:
            Image(systemName: "ellipsis.circle.fill")
                .foregroundStyle(LaterColor.Accent.queue2)
                .symbolEffect(.pulse)
        case .pending:
            Image(systemName: "circle")
                .foregroundStyle(LaterColor.Control.lineDashed)
        }
    }
}
