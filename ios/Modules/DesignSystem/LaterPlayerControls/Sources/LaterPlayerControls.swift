import LaterColor
import LaterGlass
import LaterSize
import LaterSpacing
import LaterTypography
import SwiftUI

/// `PlayerControls` from design/Later.canvas: back 15 seconds, play or pause, and next item.
public struct LaterPlayerControls: View {
    private let isPlaying: Bool
    private let onSkipBack: () -> Void
    private let onPlayPause: () -> Void
    private let onNext: () -> Void

    public init(
        isPlaying: Bool,
        onSkipBack: @escaping () -> Void,
        onPlayPause: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.isPlaying = isPlaying
        self.onSkipBack = onSkipBack
        self.onPlayPause = onPlayPause
        self.onNext = onNext
    }

    public var body: some View {
        HStack(spacing: LaterSpacing.six) {
            sideButton("Back 15 seconds", systemImage: "gobackward.15", action: onSkipBack)
            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.laterUI(.title, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(LaterColor.Accent.on)
                    .frame(width: LaterSize.playButton, height: LaterSize.playButton)
                    .background(LaterColor.Accent.base, in: Circle())
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(isPlaying ? "Pause" : "Play"))
            sideButton("Next", systemImage: "forward.end.fill", action: onNext)
        }
    }

    private func sideButton(_ label: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.laterUI(.titleSmall, weight: .semibold))
                .foregroundStyle(LaterColor.Text.ink)
                .frame(width: LaterSize.buttonLarge, height: LaterSize.buttonLarge)
                .laterGlass(in: Circle(), isInteractive: true)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}
