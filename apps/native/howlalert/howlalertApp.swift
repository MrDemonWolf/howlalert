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
	#if os(macOS)
	@NSApplicationDelegateAdaptor(MacAppDelegate.self) var macAppDelegate
	#endif

	var body: some Scene {
		#if os(macOS)
		MenuBarExtra("HowlAlert", image: "MenuBarIcon") {
			ContentView()
								.task {
					let granted = await NotificationManager.shared.requestPermission()
					if granted {
						NSApplication.shared.registerForRemoteNotifications()
					}
				}
		}
		.menuBarExtraStyle(.window)

		Settings {
			PreferencesView()
						}
		#else
		WindowGroup {
			ContentView()
						}
		#endif
	}
}

// MARK: - macOS App Delegate

#if os(macOS)
final class MacAppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		Task {
			let granted = await NotificationManager.shared.requestPermission()
			if granted {
				NSApplication.shared.registerForRemoteNotifications()
			}
		}
	}
}
#endif
