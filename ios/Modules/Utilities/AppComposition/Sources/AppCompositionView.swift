import SwiftUI
import UIKit

/// The app's whole interface. Call `AppCompositionModule.register()` before showing it.
public struct AppCompositionView: UIViewControllerRepresentable {
    public init() {}

    public func makeCoordinator() -> AppCoordinator {
        AppCoordinator()
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator.start()
        return context.coordinator.rootViewController
    }

    public func updateUIViewController(_: UIViewController, context _: Context) {}
}
