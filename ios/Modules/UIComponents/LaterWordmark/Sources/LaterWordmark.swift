import LaterColor
import LaterTypography
import SwiftUI

/// `Wordmark` from design/Later.canvas: the product name as set in the UI typeface.
public struct LaterWordmark: View {
    public init() {}

    public var body: some View {
        Text(verbatim: "later")
            .font(.laterUI(.titleSmall, weight: .semibold))
            .foregroundStyle(LaterColor.Text.ink)
            .accessibilityLabel(Text(verbatim: "Later"))
    }
}
