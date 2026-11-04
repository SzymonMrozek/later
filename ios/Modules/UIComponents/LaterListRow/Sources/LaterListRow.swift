import LaterColor
import LaterSpacing
import LaterTypography
import SwiftUI

/// `ListRow` from design/Later.canvas: a settings row with its current value and a chevron.
public struct LaterListRow: View {
    private let title: String
    private let value: String?
    private let showsChevron: Bool

    public init(_ title: String, value: String? = nil, showsChevron: Bool = true) {
        self.title = title
        self.value = value
        self.showsChevron = showsChevron
    }

    public var body: some View {
        HStack(spacing: LaterSpacing.three) {
            Text(title)
                .foregroundStyle(LaterColor.Text.ink)
            Spacer(minLength: LaterSpacing.none)
            if let value {
                Text(value)
                    .foregroundStyle(LaterColor.Text.inkMuted)
                    .lineLimit(1)
            }
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.laterUI(.footnote, weight: .semibold))
                    .foregroundStyle(LaterColor.Text.inkFaint)
                    .accessibilityHidden(true)
            }
        }
        .font(.laterUI(.bodyLarge))
        .accessibilityElement(children: .combine)
    }
}
