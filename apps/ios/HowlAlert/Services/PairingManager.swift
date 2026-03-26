import Foundation
import HowlAlertKit
import UIKit

/// Manages the iOS side of CloudKit pairing
@MainActor
final class PairingManager: ObservableObject {
	@Published var isPaired = false
	@Published var pairingError: String?

	private let cloudKit = CloudKitPairing.shared
	private let secretKey = "com.mrdemonwolf.howlalert.pairing.secret"

	/// Called after receiving APNs device token
	func registerDevice(token: String) async {
		let config = PairingConfig(
			secret: getOrCreateSecret(),
			apnsDeviceToken: token,
			deviceName: UIDevice.current.name,
			osVersion: UIDevice.current.systemVersion,
			createdAt: Date()
		)
		do {
			try await cloudKit.savePairingConfig(config)
			isPaired = true
			pairingError = nil
		} catch {
			pairingError = error.localizedDescription
		}
	}

	/// Get existing secret from UserDefaults or create new UUID
	private func getOrCreateSecret() -> String {
		if let existing = UserDefaults.standard.string(forKey: secretKey) {
			return existing
		}
		let newSecret = UUID().uuidString
		UserDefaults.standard.set(newSecret, forKey: secretKey)
		return newSecret
	}
}
