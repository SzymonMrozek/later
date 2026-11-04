import LaterCatalog
import SwiftUI

/// Until the first flows land, the app opens on the design system catalog for review.
struct RootView: View {
    var body: some View {
        LaterCatalogView()
    }

    static let title = "Later"
}

#Preview {
    RootView()
}
