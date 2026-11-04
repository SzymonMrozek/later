import LaterColor
import LaterRadius
import LaterSpacing
import LaterTypography
import SwiftUI

/// `Notice/*` from design/Later.canvas: a tinted card that explains something about the content.
public struct LaterNotice: View {
    public enum Variant: CaseIterable, Sendable {
        case info
        /// Something is missing or incomplete, such as a partly fetched article.
        case warning
    }

    private let title: String
    private let message: String
    private let variant: Variant
    private let systemImage: String

    public init(_ title: String, message: String, variant: Variant, systemImage: String? = nil) {
        self.title = title
        self.message = message
        self.variant = variant
        self.systemImage = systemImage ?? (variant == .warning ? "exclamationmark.triangle.fill" : "info.circle.fill")
    }

    public var body: some View {
        HStack(alignment: .top, spacing: LaterSpacing.three) {
            Image(systemName: systemImage)
                .font(.laterUI(.bodyLarge, weight: .semibold))
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: LaterSpacing.one) {
                Text(title)
                    .font(.laterUI(.headline))
                    .foregroundStyle(variant == .warning ? tint : LaterColor.Text.ink)
                Text(message)
                    .font(.laterUI(.body))
                    .foregroundStyle(LaterColor.Text.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(LaterSpacing.four)
        .background(background, in: RoundedRectangle(cornerRadius: LaterRadius.lg, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var tint: Color {
        variant == .warning ? LaterColor.Status.warning : LaterColor.Accent.base
    }

    private var background: Color {
        variant == .warning ? LaterColor.Status.warningSoft : LaterColor.Accent.soft
    }
}
