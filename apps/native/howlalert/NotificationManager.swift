//
//  NotificationManager.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import Foundation
import Combine
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
	static let shared = NotificationManager()

	@Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

	func checkStatus() async {
		let settings = await UNUserNotificationCenter.current().notificationSettings()
		authorizationStatus = settings.authorizationStatus
	}

	func requestPermission() async -> Bool {
		do {
			let granted = try await UNUserNotificationCenter.current()
				.requestAuthorization(options: [.alert, .badge, .sound])
			await checkStatus()
			return granted
		} catch {
			return false
		}
	}
}
