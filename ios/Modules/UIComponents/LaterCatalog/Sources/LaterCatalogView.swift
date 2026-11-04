import LaterColor
import LaterTypography
import SwiftUI

/// Every token and component, one page per group or family, for design review. The toolbar
/// switches between the system appearance, light and dark.
public struct LaterCatalogView: View {
    @State private var appearance = Appearance.system

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Tokens") {
                    ForEach(TokenPage.allCases) { page in
                        NavigationLink(page.title, value: CatalogPage.token(page))
                    }
                }
                ForEach(ComponentPage.Section.allCases, id: \.self) { section in
                    Section(section.title) {
                        ForEach(ComponentPage.allCases.filter { $0.section == section }) { page in
                            NavigationLink(page.title, value: CatalogPage.component(page))
                        }
                    }
                }
            }
            .font(.laterUI(.bodyLarge))
            .navigationTitle("Design system")
            .navigationDestination(for: CatalogPage.self) { page in
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        switch page {
                        case let .token(token): token.content
                        case let .component(component): component.content
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(LaterColor.Ground.bg)
                .navigationTitle(page.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { appearanceMenu }
            }
            .toolbar { appearanceMenu }
        }
        .tint(LaterColor.Accent.base)
        .preferredColorScheme(appearance.colorScheme)
    }

    private var appearanceMenu: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Picker("Appearance", selection: $appearance) {
                ForEach(Appearance.allCases, id: \.self) { appearance in
                    Label(appearance.title, systemImage: appearance.systemImage)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

private enum Appearance: CaseIterable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var systemImage: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

private enum CatalogPage: Hashable {
    case token(TokenPage)
    case component(ComponentPage)

    var title: String {
        switch self {
        case let .token(page): page.title
        case let .component(page): page.title
        }
    }
}

/// A labelled specimen on a catalog page.
struct Specimen<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.laterUI(.caption, weight: .medium))
                .foregroundStyle(LaterColor.Text.inkFaint)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
