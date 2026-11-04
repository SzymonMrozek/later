import LaterColor
import LaterRadius
import LaterSpacing
import LaterStroke
import LaterTypography
import SwiftUI

/// `OptionCard/*` from design/Later.canvas: one of a few choices with its length in minutes,
/// such as an article's summary or full form.
public struct LaterOptionCard: View {
    private let title: String
    private let subtitle: String
    private let minutes: Int
    private let isSelected: Bool
    private let action: () -> Void

    public init(title: String, subtitle: String, minutes: Int, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.minutes = minutes
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: LaterRadius.lg, style: .continuous)
        Button(action: action) {
            HStack(spacing: LaterSpacing.three) {
                VStack(alignment: .leading, spacing: LaterSpacing.half) {
                    Text(title)
                        .font(.laterUI(.headline))
                        .foregroundStyle(LaterColor.Text.ink)
                    Text(subtitle)
                        .font(.laterUI(.footnote))
                        .foregroundStyle(LaterColor.Text.inkMuted)
                }
                .multilineTextAlignment(.leading)
                Spacer(minLength: LaterSpacing.none)
                HStack(alignment: .lastTextBaseline, spacing: LaterSpacing.half) {
                    Text(minutes, format: .number)
                        .font(.laterUI(.numeral, weight: .semibold))
                        .foregroundStyle(LaterColor.Text.ink)
                    Text("min")
                        .font(.laterUI(.caption))
                        .foregroundStyle(LaterColor.Text.inkMuted)
                }
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.laterUI(.titleSmall, weight: .semibold))
                    .foregroundStyle(isSelected ? LaterColor.Accent.base : LaterColor.Control.lineDashed)
            }
            .padding(LaterSpacing.four)
            .background(isSelected ? LaterColor.Accent.soft : LaterColor.Ground.surface, in: shape)
            .overlay(
                shape.strokeBorder(
                    isSelected ? LaterColor.Accent.base : LaterColor.Control.line,
                    lineWidth: isSelected ? LaterStroke.selected : LaterStroke.default
                )
            )
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
