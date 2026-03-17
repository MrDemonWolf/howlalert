//
//  howlalertApp.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI
import HowlAlertKit

// MARK: - App Entry Point

@main
struct howlalertApp: App {
	#if os(iOS)
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	#endif

	var body: some Scene {
		#if os(macOS)
		MenuBarExtra("HowlAlert", systemImage: "bell.badge") {
			ContentView()
				.onAppear {
					NSApplication.shared.registerForRemoteNotifications()
				}
		}
		.menuBarExtraStyle(.window)
		#else
		WindowGroup {
			ContentView()
		}
		#endif
	}
}

// MARK: - iOS App Delegate

#if os(iOS)
final class AppDelegate: NSObject, UIApplicationDelegate {
	private let apiClient = APIClient()

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		if KeychainHelper.shared.load(key: "apple_identity_token") != nil {
			application.registerForRemoteNotifications()
		}
		return true
	}

	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		let tokenHex = deviceToken.map { String(format: "%02x", $0) }.joined()

		#if DEBUG
		let sandbox = true
		#else
		let sandbox = false
		#endif

		let platform = sandbox ? "ios-sandbox" : "ios"

		let storedToken = UserDefaults.standard.string(forKey: "lastDeviceToken")
		guard storedToken != tokenHex else { return }

		UserDefaults.standard.set(tokenHex, forKey: "lastDeviceToken")

		if let token = KeychainHelper.shared.load(key: "apple_identity_token") {
			apiClient.setAuthToken(token)
		}

		Task {
			do {
				try await apiClient.registerDevice(deviceToken: tokenHex, platform: platform)
			} catch {
				print("[HowlAlert] Device registration failed: \(error)")
			}
		}
	}

	func application(
		_ application: UIApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error
	) {
		print("[HowlAlert] Failed to register for remote notifications: \(error)")
	}
}
#endif

// MARK: - macOS App Delegate

#if os(macOS)
final class MacAppDelegate: NSObject, NSApplicationDelegate {
	private let apiClient = APIClient()

	func applicationDidFinishLaunching(_ notification: Notification) {
		if KeychainHelper.shared.load(key: "apple_identity_token") != nil {
			NSApplication.shared.registerForRemoteNotifications()
		}
	}

	func application(
		_ application: NSApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		let tokenHex = deviceToken.map { String(format: "%02x", $0) }.joined()

		#if DEBUG
		let sandbox = true
		#else
		let sandbox = false
		#endif

		let platform = sandbox ? "macos-sandbox" : "macos"

		let storedToken = UserDefaults.standard.string(forKey: "lastDeviceToken")
		guard storedToken != tokenHex else { return }

		UserDefaults.standard.set(tokenHex, forKey: "lastDeviceToken")

		if let token = KeychainHelper.shared.load(key: "apple_identity_token") {
			apiClient.setAuthToken(token)
		}

		Task {
			do {
				try await apiClient.registerDevice(deviceToken: tokenHex, platform: platform)
			} catch {
				print("[HowlAlert] Device registration failed: \(error)")
			}
		}
	}

	func application(
		_ application: NSApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error
	) {
		print("[HowlAlert] Failed to register for remote notifications: \(error)")
	}
}
#endif
