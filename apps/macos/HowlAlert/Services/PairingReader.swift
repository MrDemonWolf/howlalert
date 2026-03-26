import Foundation
import HowlAlertKit
import Security

/// Reads pairing configs from CloudKit and stores in Keychain
@MainActor
final class PairingReader: ObservableObject {
	@Published var pairedDevices: [PairingConfig] = []
	@Published var fetchError: String?

	var isPaired: Bool { !pairedDevices.isEmpty }

	private let cloudKit = CloudKitPairing.shared
	private let keychainService = "com.mrdemonwolf.howlalert.pairing"
	private let keychainSecretKey = "pairing-secret"
	private let keychainTokenKey = "pairing-device-token"

	/// Fetch pairing configs from CloudKit (called on launch)
	func fetchPairedDevices() async {
		do {
			let configs = try await cloudKit.fetchPairingConfigs()
			pairedDevices = configs

			// Store the first available pairing in Keychain for quick access
			if let primary = configs.first {
				try storeInKeychain(secret: primary.secret, deviceToken: primary.apnsDeviceToken)
			}
			fetchError = nil
		} catch {
			fetchError = error.localizedDescription
		}
	}

	/// Store pairing secret in Keychain for secure access
	private func storeInKeychain(secret: String, deviceToken: String) throws {
		try setKeychainItem(key: keychainSecretKey, value: secret)
		try setKeychainItem(key: keychainTokenKey, value: deviceToken)
	}

	/// Read stored pairing from Keychain
	func getStoredPairing() -> (secret: String, deviceToken: String)? {
		guard
			let secret = getKeychainItem(key: keychainSecretKey),
			let deviceToken = getKeychainItem(key: keychainTokenKey)
		else {
			return nil
		}
		return (secret: secret, deviceToken: deviceToken)
	}

	// MARK: - Keychain helpers

	private func setKeychainItem(key: String, value: String) throws {
		guard let data = value.data(using: .utf8) else { return }

		// Delete existing item first
		let deleteQuery: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: keychainService,
			kSecAttrAccount as String: key,
		]
		SecItemDelete(deleteQuery as CFDictionary)

		// Add new item
		let addQuery: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: keychainService,
			kSecAttrAccount as String: key,
			kSecValueData as String: data,
			kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
		]
		let status = SecItemAdd(addQuery as CFDictionary, nil)
		if status != errSecSuccess {
			throw KeychainError.unableToStore(status: status)
		}
	}

	private func getKeychainItem(key: String) -> String? {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: keychainService,
			kSecAttrAccount as String: key,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne,
		]

		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)
		guard status == errSecSuccess, let data = result as? Data else {
			return nil
		}
		return String(data: data, encoding: .utf8)
	}
}

// MARK: - Keychain error

enum KeychainError: LocalizedError {
	case unableToStore(status: OSStatus)

	var errorDescription: String? {
		switch self {
		case .unableToStore(let status):
			return "Keychain store failed with status \(status)"
		}
	}
}
