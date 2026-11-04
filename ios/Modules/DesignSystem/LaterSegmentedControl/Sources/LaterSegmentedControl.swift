import LaterColor
import LaterShadow
import LaterSpacing
import LaterTypography
import SwiftUI

/// `SegmentedControl` from design/Later.canvas: a few presets in a capsule, one of them chosen.
/// Used for playback speed, which is always presets and never a slider.
public struct LaterSegmentedControl<Option: Hashable>: View {
    @Binding private var selection: Option
    private let options: [Option]
    private let title: (Option) -> String
    @Namespace private var namespace

    public init(selection: Binding<Option>, options: [Option], title: @escaping (Option) -> String) {
        _selection = selection
        self.options = options
        self.title = title
    }

    public var body: some View {
        HStack(spacing: LaterSpacing.one) {
            ForEach(options, id: \.self) { option in
                segment(option, isSelected: option == selection)
            }
        }
        .padding(LaterSpacing.one)
        .background(LaterColor.Control.fill, in: Capsule())
    }

    private func segment(_ option: Option, isSelected: Bool) -> some View {
        Button {
            withAnimation(.snappy) { selection = option }
        } label: {
            Text(title(option))
                .font(.laterUI(.callout, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? LaterColor.Text.ink : LaterColor.Text.inkMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LaterSpacing.two)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(LaterColor.Control.fillSelected)
                            .laterShadow(.control)
                            .matchedGeometryEffect(id: "selection", in: namespace)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
