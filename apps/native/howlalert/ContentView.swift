//
//  ContentView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI
import AuthenticationServices
import HowlAlertKit

// MARK: - Root View

struct ContentView: View {
	@State private var isAuthenticated: Bool = false
	@State private var showError: Bool = false
	@State private var errorMessage: String = ""

	private let apiClient = APIClient()

	var body: some View {
		Group {
			if isAuthenticated {
				DashboardView(apiClient: apiClient)
			} else {
				signInView
			}
		}
		.onAppear {
			checkStoredToken()
		}
		.alert("Sign In Failed", isPresented: $showError) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(errorMessage)
		}
	}

	// MARK: - Sign In View

	private var signInView: some View {
		#if os(macOS)
		macSignInView
		#elseif os(iOS)
		iOSSignInView
		#elseif os(watchOS)
		watchSignInView
		#endif
	}

	#if os(macOS)
	private var macSignInView: some View {
		VStack(spacing: 16) {
			Spacer()

			Image(systemName: "bell.badge.fill")
				.font(.system(size: 48))
				.foregroundStyle(.tint)

			Text("HowlAlert")
				.font(.title)
				.fontWeight(.bold)

			Text("Monitor your Claude Code usage")
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)

			Spacer()

			SignInWithAppleButton(.signIn) { request in
				request.requestedScopes = [.email]
			} onCompletion: { result in
				handleSignInResult(result)
			}
			.signInWithAppleButtonStyle(.whiteOutline)
			.frame(height: 44)
			.padding(.horizontal)

			Spacer()
		}
		.padding()
		.frame(width: 280, height: 320)
	}
	#endif

	#if os(iOS)
	private var iOSSignInView: some View {
		NavigationStack {
			VStack(spacing: 24) {
				Spacer()

				Image(systemName: "bell.badge.fill")
					.font(.system(size: 64))
					.foregroundStyle(.tint)

				VStack(spacing: 8) {
					Text("HowlAlert")
						.font(.largeTitle)
						.fontWeight(.bold)

					Text("Monitor your Claude Code usage\nand get alerted when you hit limits.")
						.font(.body)
						.foregroundStyle(.secondary)
						.multilineTextAlignment(.center)
				}

				Spacer()

				SignInWithAppleButton(.signIn) { request in
					request.requestedScopes = [.email]
				} onCompletion: { result in
					handleSignInResult(result)
				}
				.signInWithAppleButtonStyle(.black)
				.frame(height: 50)
				.padding(.horizontal, 32)

				Spacer()
					.frame(height: 40)
			}
			.padding()
			.navigationTitle("")
			.navigationBarHidden(true)
		}
	}
	#endif

	#if os(watchOS)
	private var watchSignInView: some View {
		VStack(spacing: 8) {
			Image(systemName: "bell.badge.fill")
				.foregroundStyle(.tint)
			Text("HowlAlert")
				.font(.headline)
			Text("Open on iPhone to sign in")
				.font(.caption2)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
		}
	}
	#endif

	// MARK: - Auth Logic

	private func checkStoredToken() {
		guard let token = KeychainHelper.shared.load(key: "apple_identity_token"),
			  let _ = KeychainHelper.shared.load(key: "apple_user_id") else {
			return
		}
		apiClient.setAuthToken(token)
		isAuthenticated = true
	}

	private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
		switch result {
		case .success(let auth):
			guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
				  let tokenData = credential.identityToken,
				  let token = String(data: tokenData, encoding: .utf8) else {
				errorMessage = "Invalid credentials received from Apple."
				showError = true
				return
			}
			KeychainHelper.shared.save(key: "apple_user_id", value: credential.user)
			KeychainHelper.shared.save(key: "apple_identity_token", value: token)
			apiClient.setAuthToken(token)
			isAuthenticated = true

		case .failure(let error):
			let asError = error as? ASAuthorizationError
			// User cancelled — don't show an error
			if asError?.code == .canceled { return }
			errorMessage = error.localizedDescription
			showError = true
		}
	}
}

#Preview {
	ContentView()
}
