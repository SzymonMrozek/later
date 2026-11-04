import LaterColor
import LaterRadius
import LaterSpacing
import LaterTypography
import SwiftUI

/// `StatusTag/*` from design/Later.canvas: a small label for an article's state.
public struct LaterStatusTag: View {
    public enum Variant: CaseIterable, Sendable {
        /// Being prepared, or in progress.
        case accent
        /// Ready, or downloaded for offline.
        case positive
        case neutral
        /// Only partly fetched.
        case warning
    }

    private let title: String
    private let variant: Variant

    public init(_ title: String, variant: Variant) {
        self.title = title
        self.variant = variant
    }

    public var body: some View {
        Text(title)
            .font(.laterUI(.tag, weight: .semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, LaterSpacing.two)
            .padding(.vertical, LaterSpacing.half)
            .background(background, in: RoundedRectangle(cornerRadius: LaterRadius.xs, style: .continuous))
    }

    private var foreground: Color {
        switch variant {
        case .accent: LaterColor.Accent.base
        case .positive: LaterColor.Status.positive
        case .neutral: LaterColor.Text.inkMuted
        case .warning: LaterColor.Status.warning
        }
    }

    private var background: Color {
        switch variant {
        case .accent: LaterColor.Accent.soft
        case .positive: LaterColor.Status.positiveSoft
        case .neutral: LaterColor.Control.fill
        case .warning: LaterColor.Status.warningSoft
        }
    }
}
