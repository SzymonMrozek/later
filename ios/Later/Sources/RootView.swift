import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text(RootView.title)
                .font(.largeTitle.weight(.semibold))
            Text("Ile masz czasu?")
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    static let title = "Later"
}

#Preview {
    RootView()
}
