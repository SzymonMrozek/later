import AppleSignInInterface
import AuthenticationServices
import UIKit

/// Sign in with Apple through `ASAuthorizationController`, asking for the person's name and email.
final class AuthenticationServicesAppleSignInClient: NSObject, AppleSignInClient {
    private var pending: CheckedContinuation<AppleIDCredential, any Error>?

    func signIn() async throws(AppleSignInError) -> AppleIDCredential {
        guard pending == nil else {
            throw .failed
        }
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        do {
            return try await withCheckedThrowingContinuation { continuation in
                pending = continuation
                controller.performRequests()
            }
        } catch let error as AppleSignInError {
            throw error
        } catch {
            throw .failed
        }
    }

    private func finish(_ result: Result<AppleIDCredential, AppleSignInError>) {
        pending?.resume(with: result.mapError { $0 as any Error })
        pending = nil
    }
}

extension AuthenticationServicesAppleSignInClient: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        let credential = authorization.credential as? ASAuthorizationAppleIDCredential
        let result: Result<AppleIDCredential, AppleSignInError> = if let credential,
                                                                     let identityToken = credential.identityToken
                                                                         .flatMap({ String(
                                                                             data: $0,
                                                                             encoding: .utf8
                                                                         ) }),
                                                                     let authorizationCode = credential
                                                                         .authorizationCode.flatMap({ String(
                                                                             data: $0,
                                                                             encoding: .utf8
                                                                         ) })
        {
            .success(AppleIDCredential(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                givenName: credential.fullName?.givenName,
                familyName: credential.fullName?.familyName,
                email: credential.email
            ))
        } else {
            .failure(.failed)
        }
        MainActor.assumeIsolated { finish(result) }
    }

    nonisolated func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        let cancelled = (error as? ASAuthorizationError)?.code == .canceled
        MainActor.assumeIsolated { finish(.failure(cancelled ? .cancelled : .failed)) }
    }
}

extension AuthenticationServicesAppleSignInClient: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
        }
    }
}
