import LaterColor
import LaterGlass
import LaterSize
import LaterTypography
import SwiftUI

/// `IconButton/*` from design/Later.canvas: a round SF Symbol button at the minimum tap size.
public struct LaterIconButton: View {
    public enum Variant: CaseIterable, Sendable {
        /// Liquid Glass, for controls floating over content: close, back, more.
        case glass
        /// The accent's soft fill, for adding.
        case tonal
    }

    private let systemImage: String
    private let accessibilityLabel: String
    private let variant: Variant
    private let action: () -> Void

    public init(
        _ accessibilityLabel: String,
        systemImage: String,
        variant: Variant = .glass,
        action: @escaping () -> Void
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.systemImage = systemImage
        self.variant = variant
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.laterUI(.body, weight: .semibold))
                .frame(width: LaterSize.tap, height: LaterSize.tap)
                .contentShape(Circle())
        }
        .buttonStyle(IconButtonStyle(variant: variant))
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct IconButtonStyle: ButtonStyle {
    let variant: LaterIconButton.Variant

    func makeBody(configuration: Configuration) -> some View {
        switch variant {
        case .glass:
            configuration.label
                .foregroundStyle(LaterColor.Text.ink)
                .laterGlass(in: Circle(), isInteractive: true)
        case .tonal:
            configuration.label
                .foregroundStyle(LaterColor.Accent.base)
                .background(LaterColor.Accent.soft, in: Circle())
                .opacity(configuration.isPressed ? 0.7 : 1)
        }
    }
}
