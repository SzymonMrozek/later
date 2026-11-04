import LaterColor
import LaterGlass
import LaterSpacing
import LaterTypography
import SwiftUI

/// `TabBar` from design/Later.canvas: the app's sections in a floating glass capsule.
public struct LaterTabBar<Tab: Hashable>: View {
    public struct Item: Hashable {
        public let tab: Tab
        public let title: String
        public let systemImage: String
        /// The symbol while selected, usually the filled one.
        public let selectedSystemImage: String

        public init(_ tab: Tab, title: String, systemImage: String, selectedSystemImage: String? = nil) {
            self.tab = tab
            self.title = title
            self.systemImage = systemImage
            self.selectedSystemImage = selectedSystemImage ?? systemImage
        }
    }

    @Binding private var selection: Tab
    private let items: [Item]
    @Namespace private var namespace

    public init(selection: Binding<Tab>, items: [Item]) {
        _selection = selection
        self.items = items
    }

    public var body: some View {
        HStack(spacing: LaterSpacing.none) {
            ForEach(items, id: \.self) { item in
                tab(item, isSelected: item.tab == selection)
            }
        }
        .padding(LaterSpacing.one)
        .laterGlass(in: Capsule())
    }

    private func tab(_ item: Item, isSelected: Bool) -> some View {
        Button {
            withAnimation(.snappy) { selection = item.tab }
        } label: {
            VStack(spacing: LaterSpacing.half) {
                Image(systemName: isSelected ? item.selectedSystemImage : item.systemImage)
                    .font(.laterUI(.titleSmall, weight: .semibold))
                Text(item.title)
                    .font(.laterUI(.tag, weight: .semibold))
            }
            .foregroundStyle(isSelected ? LaterColor.Accent.base : LaterColor.Text.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, LaterSpacing.two)
            .background {
                if isSelected {
                    Capsule()
                        .fill(LaterColor.Glass.selected)
                        .matchedGeometryEffect(id: "selection", in: namespace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}
