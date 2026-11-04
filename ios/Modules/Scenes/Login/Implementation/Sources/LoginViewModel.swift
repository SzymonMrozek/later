import Observation

enum LoginMethod: Equatable {
    case apple
    case guest
}

enum LoginFailure: Equatable {
    case offline
    case failed
}

enum LoginState: Equatable {
    case idle
    case signingIn(LoginMethod)
    /// The last attempt failed; the person can try again.
    case failed(LoginFailure)

    var isSigningIn: Bool {
        if case .signingIn = self {
            return true
        }
        return false
    }
}

/// What the welcome screen shows. The interactor changes it; the view only reads it.
@Observable
final class LoginViewModel {
    var state = LoginState.idle
}
