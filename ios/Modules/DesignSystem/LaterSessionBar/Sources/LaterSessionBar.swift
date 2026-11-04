import LaterColor
import LaterRadius
import LaterSize
import LaterSpacing
import SwiftUI

/// `SessionBar` from design/Later.canvas: how a listening session fills the time you have.
/// Each item is a segment as long as its length, in its session color; the rest is free time.
public struct LaterSessionBar: View {
    private let lengths: [Double]
    private let available: Double

    /// - Parameters:
    ///   - lengths: Each item's length, in session order, in any one unit.
    ///   - available: The time you have, in the same unit.
    public init(lengths: [Double], available: Double) {
        self.lengths = lengths
        self.available = available
    }

    public var body: some View {
        let layout = Self.layout(lengths: lengths, available: available)
        GeometryReader { proxy in
            let gaps = LaterSpacing.one * CGFloat(max(layout.count - 1, 0))
            let width = max(proxy.size.width - gaps, 0)
            HStack(spacing: LaterSpacing.one) {
                ForEach(layout, id: \.self) { segment in
                    RoundedRectangle(cornerRadius: LaterRadius.xs, style: .continuous)
                        .fill(segment.position.map(LaterColor.Accent.session) ?? LaterColor.Control.fill)
                        .frame(width: width * segment.fraction)
                }
            }
        }
        .frame(height: LaterSize.sessionBar)
        .accessibilityElement()
        .accessibilityLabel(Text("Session"))
        .accessibilityValue(Text(Self.layout(lengths: lengths, available: available).accessibilityValue))
    }

    struct Segment: Hashable {
        /// The item's place in the session, or nil for the free time after the last one.
        let position: Int?
        let fraction: Double
    }

    /// The segments to draw, as fractions of the bar. Empty items are left out; a session longer
    /// than the time you have fills the bar with no free time.
    nonisolated static func layout(lengths: [Double], available: Double) -> [Segment] {
        let used = lengths.map { max($0, 0) }.reduce(0, +)
        let total = max(used, available)
        guard total > 0 else {
            return []
        }
        var segments = lengths.enumerated()
            .filter { $0.element > 0 }
            .map { Segment(position: $0.offset, fraction: $0.element / total) }
        if available > used {
            segments.append(Segment(position: nil, fraction: (available - used) / total))
        }
        return segments
    }
}

private extension [LaterSessionBar.Segment] {
    var accessibilityValue: String {
        let used = filter { $0.position != nil }.map(\.fraction).reduce(0, +)
        return "\(count(where: { $0.position != nil })) items, \(Int((used * 100).rounded())) percent of your time"
    }
}
