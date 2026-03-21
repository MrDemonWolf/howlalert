import Foundation
import UserNotifications

@MainActor
public final class ThresholdNotifier: ObservableObject {
	public static let shared = ThresholdNotifier()

	private let defaults: UserDefaults
	private let notificationCenter = UNUserNotificationCenter.current()

	private init() {
		self.defaults = UserDefaults(suiteName: "group.com.mrdemonwolf.howlalert") ?? .standard
	}

	/// Check current usage against thresholds and fire notifications for newly exceeded ones.
	/// Call this after each data refresh (scan or iCloud sync).
	public func checkThresholds(
		dailyCost: Double,
		totalTokens: Int,
		sessionCount: Int,
		thresholds: [AlertThreshold]
	) {
		let today = todayKey()

		for threshold in thresholds where threshold.isEnabled {
			let currentValue: Double
			switch threshold.type {
			case .dailyCost:
				currentValue = dailyCost
			case .tokenCount:
				currentValue = Double(totalTokens)
			case .sessionCount:
				currentValue = Double(sessionCount)
			}

			let isExceeded = currentValue >= threshold.value
			let notifiedKey = "threshold_notified_\(threshold.type.rawValue)_\(today)"
			let wasNotified = defaults.bool(forKey: notifiedKey)

			if isExceeded && !wasNotified {
				// State transition: available → depleted
				defaults.set(true, forKey: notifiedKey)
				fireNotification(for: threshold, currentValue: currentValue)
			}
		}

		// Clean up old notification keys (keep only today's)
		pruneOldKeys(currentDay: today)
	}

	private func fireNotification(for threshold: AlertThreshold, currentValue: Double) {
		let content = UNMutableNotificationContent()
		content.sound = .default

		switch threshold.type {
		case .dailyCost:
			content.title = "Daily Cost Limit Reached"
			content.body = String(format: "You've spent $%.2f today (limit: $%.2f)", currentValue, threshold.value)
		case .tokenCount:
			content.title = "Token Limit Reached"
			let formatter = NumberFormatter()
			formatter.numberStyle = .decimal
			let current = formatter.string(from: NSNumber(value: Int(currentValue))) ?? "\(Int(currentValue))"
			let limit = formatter.string(from: NSNumber(value: Int(threshold.value))) ?? "\(Int(threshold.value))"
			content.body = "You've used \(current) tokens today (limit: \(limit))"
		case .sessionCount:
			content.title = "Session Limit Reached"
			content.body = "You've had \(Int(currentValue)) sessions today (limit: \(Int(threshold.value)))"
		}

		let request = UNNotificationRequest(
			identifier: "howlalert.threshold.\(threshold.type.rawValue).\(todayKey())",
			content: content,
			trigger: nil  // fire immediately
		)

		notificationCenter.add(request) { error in
			if let error {
				print("[HowlAlert] Failed to fire notification: \(error)")
			}
		}
	}

	private func todayKey() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter.string(from: Date())
	}

	private func pruneOldKeys(currentDay: String) {
		let prefix = "threshold_notified_"
		for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
			if !key.hasSuffix(currentDay) {
				defaults.removeObject(forKey: key)
			}
		}
	}
}
