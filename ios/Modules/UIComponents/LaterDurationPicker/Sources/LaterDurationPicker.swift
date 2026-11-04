import LaterColor
import LaterRadius
import LaterSize
import LaterSpacing
import LaterStroke
import LaterTypography
import SwiftUI

/// `DurationPicker` from design/Later.canvas: "How much time do you have?" as a row of minute
/// tiles that scrolls sideways.
public struct LaterDurationPicker: View {
    /// The tiles on the Now screen: 10 to 120 minutes.
    public static let standardMinutes = [10, 20, 30, 45, 60, 90, 120]

    @Binding private var minutes: Int
    private let options: [Int]

    public init(minutes: Binding<Int>, options: [Int] = Self.standardMinutes) {
        _minutes = minutes
        self.options = options
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LaterSpacing.two) {
                    ForEach(options, id: \.self) { option in
                        tile(option, isSelected: option == minutes)
                            .id(option)
                    }
                }
            }
            .onAppear { proxy.scrollTo(minutes) }
        }
    }

    private func tile(_ option: Int, isSelected: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: LaterRadius.lg, style: .continuous)
        return Button {
            withAnimation(.snappy) { minutes = option }
        } label: {
            VStack(spacing: LaterSpacing.none) {
                Text(option, format: .number)
                    .font(.laterUI(.numeral, weight: .semibold))
                    .foregroundStyle(isSelected ? LaterColor.Accent.on : LaterColor.Text.ink)
                Text("min")
                    .font(.laterUI(.caption))
                    .foregroundStyle(isSelected ? LaterColor.Accent.on : LaterColor.Text.inkMuted)
            }
            .padding(.vertical, LaterSpacing.three)
            .frame(width: LaterSize.thumbLarge)
            .background(isSelected ? LaterColor.Accent.base : LaterColor.Overlay.clear, in: shape)
            .overlay {
                if !isSelected {
                    shape.strokeBorder(LaterColor.Control.line, lineWidth: LaterStroke.default)
                }
            }
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("\(option) minutes"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
