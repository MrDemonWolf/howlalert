import SwiftUI

@main
struct HowlAlertApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		MenuBarExtra("HowlAlert", systemImage: "chart.bar.fill") {
			MenuBarView()
		}
		.menuBarExtraStyle(.window)
	}
}

final class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		// Register for remote notifications
		NSApplication.shared.registerForRemoteNotifications()
	}

	func application(
		_ application: NSApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		let token = deviceToken.map { String(format: "%02x", $0) }.joined()
		print("APNs token: \(token)")
	}

	func application(
		_ application: NSApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error
	) {
		print("Failed to register for APNs: \(error)")
	}
}
