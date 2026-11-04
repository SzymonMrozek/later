import LaterButton
import LaterColor
import LaterNotice
import LaterSpacing
import LaterStepIndicator
import LaterTypography
import LaterWordmark
import SwiftUI

/// 1.1 Welcome in design/Later.canvas.
struct LoginView: View {
    let viewModel: LoginViewModel
    let interactor: LoginInteractor

    var body: some View {
        VStack(alignment: .leading, spacing: LaterSpacing.four) {
            LaterStepIndicator(count: 3, current: 0)
            Spacer()
            LaterWordmark()
            Text(L10n.title)
                .font(.laterUI(.title, weight: .semibold))
                .foregroundStyle(LaterColor.Text.ink)
            Text(L10n.subtitle)
                .font(.laterUI(.bodyLarge))
                .foregroundStyle(LaterColor.Text.inkMuted)
            Spacer()
            if case let .failed(failure) = viewModel.state {
                failureNotice(failure)
                    .transition(.opacity)
            }
            VStack(spacing: LaterSpacing.two) {
                LaterButton(
                    L10n.continueWithApple,
                    systemImage: "apple.logo",
                    variant: .ink,
                    isLoading: viewModel.state == .signingIn(.apple)
                ) {
                    Task { await interactor.signInWithApple() }
                }
                .disabled(isWaiting(for: .guest))
                LaterButton(
                    L10n.continueWithoutAccount,
                    variant: .quiet,
                    isLoading: viewModel.state == .signingIn(.guest)
                ) {
                    Task { await interactor.continueAsGuest() }
                }
                .disabled(isWaiting(for: .apple))
            }
            Text(L10n.accountLater)
                .font(.laterUI(.footnote))
                .foregroundStyle(LaterColor.Text.inkMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, LaterSpacing.six)
        .padding(.vertical, LaterSpacing.two)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LaterColor.Ground.bg)
        .animation(.snappy, value: viewModel.state)
    }

    /// Dims a button while the other one's sign-in runs. The running one keeps its look and shows a spinner;
    /// the interactor ignores a second tap.
    private func isWaiting(for method: LoginMethod) -> Bool {
        viewModel.state == .signingIn(method)
    }

    @ViewBuilder private func failureNotice(_ failure: LoginFailure) -> some View {
        switch failure {
        case .offline:
            LaterNotice(L10n.offlineTitle, message: L10n.offlineMessage, variant: .warning, systemImage: "wifi.slash")
        case .failed:
            LaterNotice(L10n.failedTitle, message: L10n.failedMessage, variant: .warning)
        }
    }
}

#Preview("Welcome") {
    LoginView(viewModel: LoginViewModel(), interactor: PreviewLoginInteractor())
}

#Preview("Offline") {
    let viewModel = LoginViewModel()
    viewModel.state = .failed(.offline)
    return LoginView(viewModel: viewModel, interactor: PreviewLoginInteractor())
}

private struct PreviewLoginInteractor: LoginInteractor {
    func signInWithApple() async {}
    func continueAsGuest() async {}
}
