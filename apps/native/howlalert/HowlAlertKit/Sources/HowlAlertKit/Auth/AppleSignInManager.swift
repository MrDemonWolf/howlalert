import Foundation
import AuthenticationServices

public final class AppleSignInManager: NSObject, ObservableObject {
    @Published public var isSignedIn: Bool = false
    @Published public var userId: String?

    public static let shared = AppleSignInManager()

    private override init() {
        super.init()
        checkExistingCredentials()
    }

    public func signIn() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.email]
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = SignInDelegate(continuation: continuation)
            controller.delegate = delegate
            objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            controller.performRequests()
        }
    }

    private func checkExistingCredentials() {
        guard let userId = KeychainHelper.shared.load(key: "apple_user_id"),
              KeychainHelper.shared.load(key: "apple_identity_token") != nil else {
            return
        }
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { [weak self] state, _ in
            DispatchQueue.main.async {
                self?.isSignedIn = state == .authorized
                self?.userId = state == .authorized ? userId : nil
            }
        }
    }

    public func signOut() {
        KeychainHelper.shared.delete(key: "apple_user_id")
        KeychainHelper.shared.delete(key: "apple_identity_token")
        isSignedIn = false
        userId = nil
    }
}

private final class SignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    let continuation: CheckedContinuation<String, Error>

    nonisolated init(continuation: CheckedContinuation<String, Error>) {
        self.continuation = continuation
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let token = String(data: tokenData, encoding: .utf8) else {
            continuation.resume(throwing: AuthError.invalidCredential)
            return
        }
        KeychainHelper.shared.save(key: "apple_user_id", value: credential.user)
        KeychainHelper.shared.save(key: "apple_identity_token", value: token)
        continuation.resume(returning: token)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation.resume(throwing: error)
    }
}

public enum AuthError: Error {
    case invalidCredential
    case notSignedIn
}
