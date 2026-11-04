import LaterColor
import LaterIconButton
import LaterSize
import LaterTypography
import SwiftUI

/// `NavBar` from design/Later.canvas: a centered title under a small kicker, between two glass
/// icon buttons. For full-screen views such as the player, which draw their own bar.
public struct LaterNavBar: View {
    private let kicker: String?
    private let title: String
    private let leading: LaterIconButton?
    private let trailing: LaterIconButton?

    public init(
        title: String,
        kicker: String? = nil,
        leading: LaterIconButton? = nil,
        trailing: LaterIconButton? = nil
    ) {
        self.title = title
        self.kicker = kicker
        self.leading = leading
        self.trailing = trailing
    }

    public var body: some View {
        HStack {
            slot(leading)
            Spacer()
            VStack(spacing: .zero) {
                if let kicker {
                    Text(kicker)
                        .font(.laterUI(.eyebrow, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(LaterColor.Text.inkMuted)
                }
                Text(title)
                    .font(.laterUI(.headline))
                    .foregroundStyle(LaterColor.Text.ink)
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            Spacer()
            slot(trailing)
        }
    }

    @ViewBuilder private func slot(_ button: LaterIconButton?) -> some View {
        if let button {
            button
        } else {
            Color.clear.frame(width: LaterSize.tap, height: LaterSize.tap)
        }
    }
}
