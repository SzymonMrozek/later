import UIKit

/// Owns a flow's navigation. A scene's entry point returns one attached to the caller's navigation
/// controller; the caller starts it and keeps it for as long as the flow lives.
public protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
