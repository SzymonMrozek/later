import LaterColor
import LaterRadius
import LaterSpacing
import LaterTypography
import SwiftUI

/// `Sheet` from design/Later.canvas: a title with a text action over the sheet's content.
/// Present it with `.sheet` and `.laterSheetPresentation()`; the system draws the grabber.
public struct LaterSheet<Content: View>: View {
    private let title: String
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let content: Content

    public init(
        _ title: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: LaterSpacing.four) {
            HStack {
                Text(title)
                    .font(.laterUI(.headline))
                    .foregroundStyle(LaterColor.Text.ink)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .font(.laterUI(.bodyLarge))
                        .foregroundStyle(LaterColor.Accent.base)
                }
            }
            content
        }
        .padding(LaterSpacing.five)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public extension View {
    /// The sheet's surface, corner radius and grabber, for content presented with `.sheet`.
    func laterSheetPresentation() -> some View {
        presentationBackground(LaterColor.Ground.surface)
            .presentationCornerRadius(LaterRadius.sheet)
            .presentationDragIndicator(.visible)
    }
}
