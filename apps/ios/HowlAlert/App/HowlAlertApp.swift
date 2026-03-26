import SwiftUI

@main
struct HowlAlertApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}

final class AppDelegate: NSObject, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		UNUserNotificationCenter.current().requestAuthorization(
			options: [.alert, .sound, .badge]
		) { granted, error in
			if granted {
				DispatchQueue.main.async {
					application.registerForRemoteNotifications()
				}
			}
		}
		return true
	}

	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		let token = deviceToken.map { String(format: "%02x", $0) }.joined()
		print("APNs token: \(token)")
		// TODO: Write to CloudKit PairingConfig
	}
}
