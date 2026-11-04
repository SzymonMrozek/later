import LaterColor
import LaterTypography
import SwiftUI

/// `SectionHeader` from design/Later.canvas: an uppercase eyebrow with an optional text action.
public struct LaterSectionHeader: View {
    private let title: String
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(_ title: String) {
        self.title = title
        actionTitle = nil
        action = nil
    }

    public init(_ title: String, actionTitle: String, action: @escaping () -> Void) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(.laterUI(.eyebrow, weight: .semibold))
                .textCase(.uppercase)
                .foregroundStyle(LaterColor.Text.inkMuted)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.laterUI(.callout, weight: .medium))
                    .foregroundStyle(LaterColor.Accent.base)
            }
        }
    }
}
