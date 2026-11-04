import LaterColor
import LaterSize
import LaterSpacing
import LaterTypography
import SwiftUI

/// `Button/*` from design/Later.canvas: a full-width capsule, or a text-only destructive action.
public struct LaterButton: View {
    private let title: String
    private let systemImage: String?
    private let variant: LaterButtonStyle.Variant
    private let action: () -> Void

    public init(
        _ title: String,
        systemImage: String? = nil,
        variant: LaterButtonStyle.Variant = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.variant = variant
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            if let systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
        }
        .buttonStyle(LaterButtonStyle(variant))
    }
}

public struct LaterButtonStyle: ButtonStyle {
    public enum Variant: CaseIterable, Sendable {
        /// The one primary action on a screen, in the accent.
        case primary
        case secondary
        /// Sign in with Apple and other actions that must read as black or white.
        case ink
        /// A text-only alternative to the primary action.
        case quiet
        /// Text-only, for actions that delete data.
        case destructive
    }

    @Environment(\.isEnabled) private var isEnabled
    private let variant: Variant

    public init(_ variant: Variant) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundStyle(foreground)
            .padding(.horizontal, LaterSpacing.five)
            .frame(maxWidth: variant == .destructive ? nil : .infinity, minHeight: minHeight)
            .background(background, in: Capsule())
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
            .opacity(isEnabled ? 1 : 0.4)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private var font: Font {
        variant == .destructive ? .laterUI(.bodyLarge) : .laterUI(.headline)
    }

    private var minHeight: CGFloat {
        switch variant {
        case .primary, .secondary, .ink: LaterSize.buttonLarge
        case .quiet, .destructive: LaterSize.tap
        }
    }

    private var foreground: Color {
        switch variant {
        case .primary: LaterColor.Accent.on
        case .secondary: LaterColor.Text.ink
        case .ink: LaterColor.Text.onInk
        case .quiet: LaterColor.Accent.base
        case .destructive: LaterColor.Status.danger
        }
    }

    private var background: Color {
        switch variant {
        case .primary: LaterColor.Accent.base
        case .secondary: LaterColor.Control.fill
        case .ink: LaterColor.Text.ink
        case .quiet, .destructive: LaterColor.Overlay.clear
        }
    }
}

public extension ButtonStyle where Self == LaterButtonStyle {
    static func later(_ variant: LaterButtonStyle.Variant) -> LaterButtonStyle {
        LaterButtonStyle(variant)
    }
}
