import LaterArticleThumb
import LaterColor
import LaterGlass
import LaterSize
import LaterSpacing
import LaterTypography
import SwiftUI

/// `MiniPlayer` from design/Later.canvas: the session that's playing, floating above the tab bar.
/// Tapping it opens the player; the toggle plays and pauses.
public struct LaterMiniPlayer: View {
    private let title: String
    private let subtitle: String
    private let image: Image?
    private let isPlaying: Bool
    private let onOpen: () -> Void
    private let onPlayPause: () -> Void

    /// - Parameters:
    ///   - subtitle: Where the session is, such as "Session · 12:40 left".
    public init(
        title: String,
        subtitle: String,
        image: Image? = nil,
        isPlaying: Bool,
        onOpen: @escaping () -> Void,
        onPlayPause: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.isPlaying = isPlaying
        self.onOpen = onOpen
        self.onPlayPause = onPlayPause
    }

    public var body: some View {
        HStack(spacing: LaterSpacing.three) {
            Button(action: onOpen) {
                HStack(spacing: LaterSpacing.three) {
                    LaterArticleThumb(image: image, size: .small)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: LaterSpacing.none) {
                        Text(title)
                            .font(.laterUI(.callout, weight: .medium))
                            .foregroundStyle(LaterColor.Text.ink)
                        Text(subtitle)
                            .font(.laterUI(.caption))
                            .foregroundStyle(LaterColor.Text.inkMuted)
                    }
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint(Text("Opens the player"))
            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.laterUI(.titleSmall, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(LaterColor.Text.ink)
                    .frame(width: LaterSize.thumbSmall, height: LaterSize.thumbSmall)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(isPlaying ? "Pause" : "Play"))
        }
        .padding(LaterSpacing.two)
        .laterGlass(in: Capsule())
    }
}
