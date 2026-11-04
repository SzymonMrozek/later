import LaterColor
import LaterSpacing
import LaterStroke
import LaterTypography
import SwiftUI

/// `Chip/*` from design/Later.canvas: a capsule for categories, filters and languages.
public struct LaterChip: View {
    public enum Variant: Equatable, Sendable {
        case `default`
        case selected
        /// A chosen language; `isMain` adds the "main" mark.
        case language(isMain: Bool)
        /// Dashed, with a plus, for adding another chip.
        case add
    }

    private let title: String
    private let variant: Variant
    private let action: () -> Void

    public init(_ title: String, variant: Variant = .default, action: @escaping () -> Void) {
        self.title = title
        self.variant = variant
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: LaterSpacing.one) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.laterUI(.tag, weight: .semibold))
                }
                Text(title)
                    .font(.laterUI(.callout, weight: .medium))
                if variant == .language(isMain: true) {
                    Text("· main")
                        .font(.laterUI(.tag, weight: .semibold))
                }
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, LaterSpacing.four)
            .padding(.vertical, LaterSpacing.two)
            .background(background, in: Capsule())
            .overlay(border)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var isSelected: Bool {
        switch variant {
        case .selected, .language: true
        case .default, .add: false
        }
    }

    private var systemImage: String? {
        switch variant {
        case .language: "checkmark"
        case .add: "plus"
        case .default, .selected: nil
        }
    }

    private var foreground: Color {
        switch variant {
        case .default: LaterColor.Text.ink
        case .selected: LaterColor.Text.onInk
        case .language: LaterColor.Accent.on
        case .add: LaterColor.Text.inkMuted
        }
    }

    private var background: Color {
        switch variant {
        case .default: LaterColor.Ground.bg
        case .selected: LaterColor.Text.ink
        case .language: LaterColor.Accent.base
        case .add: LaterColor.Overlay.clear
        }
    }

    @ViewBuilder private var border: some View {
        switch variant {
        case .default:
            Capsule().strokeBorder(LaterColor.Control.line, lineWidth: LaterStroke.default)
        case .add:
            Capsule().strokeBorder(
                LaterColor.Control.lineDashed,
                style: StrokeStyle(lineWidth: LaterStroke.default, dash: LaterStroke.dash)
            )
        case .selected, .language:
            EmptyView()
        }
    }
}
