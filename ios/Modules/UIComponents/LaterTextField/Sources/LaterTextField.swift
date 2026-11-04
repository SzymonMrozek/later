import LaterColor
import LaterRadius
import LaterSize
import LaterSpacing
import LaterTypography
import SwiftUI

/// `TextField/*` from design/Later.canvas: a labelled field, or a search capsule.
public struct LaterTextField: View {
    public enum Variant: Equatable, Sendable {
        /// A rounded field under a small label.
        case labeled(String)
        /// A capsule with a magnifying glass.
        case search
    }

    @Binding private var text: String
    private let prompt: String
    private let variant: Variant

    public init(text: Binding<String>, prompt: String, variant: Variant) {
        _text = text
        self.prompt = prompt
        self.variant = variant
    }

    public var body: some View {
        switch variant {
        case let .labeled(label):
            VStack(alignment: .leading, spacing: LaterSpacing.two) {
                Text(label)
                    .font(.laterUI(.footnote, weight: .medium))
                    .foregroundStyle(LaterColor.Text.inkMuted)
                field
                    .padding(.horizontal, LaterSpacing.four)
                    .frame(minHeight: LaterSize.row)
                    .background(
                        LaterColor.Control.fill,
                        in: RoundedRectangle(cornerRadius: LaterRadius.md, style: .continuous)
                    )
            }
        case .search:
            HStack(spacing: LaterSpacing.two) {
                Image(systemName: "magnifyingglass")
                    .font(.laterUI(.bodyLarge, weight: .semibold))
                    .foregroundStyle(LaterColor.Text.inkMuted)
                field
            }
            .padding(.horizontal, LaterSpacing.four)
            .frame(minHeight: LaterSize.tap)
            .background(LaterColor.Control.fill, in: Capsule())
        }
    }

    private var field: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(prompt).foregroundStyle(LaterColor.Text.inkMuted)
        )
        .font(.laterUI(.bodyLarge))
        .foregroundStyle(LaterColor.Text.ink)
        .tint(LaterColor.Accent.base)
    }
}
