import AppComposition
import SwiftUI

@main
struct LaterApp: App {
    init() {
        AppCompositionModule.register()
    }

    var body: some Scene {
        WindowGroup {
            AppCompositionView()
                .ignoresSafeArea()
        }
    }
}
