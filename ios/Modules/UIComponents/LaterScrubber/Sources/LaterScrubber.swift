import LaterColor
import LaterRadius
import LaterSize
import LaterSpacing
import LaterTypography
import SwiftUI

/// `Scrubber` from design/Later.canvas: playback progress with elapsed and remaining time.
/// Dragging along the bar seeks.
public struct LaterScrubber: View {
    private let elapsed: TimeInterval
    private let duration: TimeInterval
    private let onSeek: (TimeInterval) -> Void
    @State private var dragProgress: Double?

    public init(elapsed: TimeInterval, duration: TimeInterval, onSeek: @escaping (TimeInterval) -> Void) {
        self.elapsed = elapsed
        self.duration = duration
        self.onSeek = onSeek
    }

    public var body: some View {
        let progress = dragProgress ?? Self.progress(elapsed: elapsed, duration: duration)
        let shown = progress * max(duration, 0)
        VStack(spacing: LaterSpacing.two) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(LaterColor.Control.fill)
                    Capsule().fill(LaterColor.Accent.base)
                        .frame(width: proxy.size.width * progress)
                }
                .frame(height: LaterSize.track)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(seekGesture(width: proxy.size.width))
            }
            .frame(height: LaterSize.tap / 2)
            HStack {
                Text(Self.time(shown))
                Spacer()
                Text(Self.remaining(shown, of: duration))
            }
            .font(.laterUI(.caption, weight: .medium).monospacedDigit())
            .foregroundStyle(LaterColor.Text.inkMuted)
        }
        .accessibilityElement()
        .accessibilityLabel(Text("Playback position"))
        .accessibilityValue(Text("\(Self.time(shown)) of \(Self.time(duration))"))
        .accessibilityAdjustableAction { direction in
            let step: TimeInterval = direction == .increment ? 15 : -15
            onSeek(min(max(elapsed + step, 0), duration))
        }
    }

    private func seekGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                dragProgress = min(max(value.location.x / max(width, 1), 0), 1)
            }
            .onEnded { _ in
                if let dragProgress {
                    onSeek(dragProgress * duration)
                }
                dragProgress = nil
            }
    }

    nonisolated static func progress(elapsed: TimeInterval, duration: TimeInterval) -> Double {
        guard duration > 0 else {
            return 0
        }
        return min(max(elapsed / duration, 0), 1)
    }

    /// "8:05", or "1:02:03" from an hour.
    nonisolated static func time(_ interval: TimeInterval) -> String {
        let seconds = Int(max(interval, 0).rounded(.down))
        let (hours, minutes, rest) = (seconds / 3600, seconds / 60 % 60, seconds % 60)
        let tail = String(format: "%02d", rest)
        return hours > 0 ? "\(hours):\(String(format: "%02d", minutes)):\(tail)" : "\(minutes):\(tail)"
    }

    /// The time left, with a minus sign: "−8:40".
    nonisolated static func remaining(_ elapsed: TimeInterval, of duration: TimeInterval) -> String {
        "\u{2212}" + time(max(duration, 0) - min(max(elapsed, 0), max(duration, 0)))
    }
}
