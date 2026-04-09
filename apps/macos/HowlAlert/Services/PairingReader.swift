import Foundation
import HowlAlertKit
import CloudKit
import Security

/// Reads pairing configs from CloudKit and stores credentials in Keychain.
@MainActor
final class PairingReader: ObservableObject {
	@Published var pairedDevices: [PairingConfig] = []
	@Published var fetchError: String?

	var isPaired: Bool { !pairedDevices.isEmpty }

	private let container = CKContainer(identifier: "iCloud.com.mrdemonwolf.howlalert")
	private let keychainService = "com.mrdemonwolf.howlalert.pairing"
	private let keychainSecretKey = "pairing-secret"
	private let keychainTokenKey = "pairing-device-token"

	/// Fetch pairing configs from CloudKit (called on launch).
	func fetchPairedDevices() async {
		do {
			let db = container.privateCloudDatabase
			let query = CKQuery(recordType: "PairingConfig", predicate: NSPredicate(value: true))
			let result = try await db.records(matching: query)
			let configs = result.matchResults.compactMap { _, outcome -> PairingConfig? in
				guard let record = try? outcome.get() else { return nil }
				return PairingConfig(record: record)
			}
			pairedDevices = configs

			// Store the first available pairing in Keychain for quick access
			if let primary = configs.first {
				try storeInKeychain(secret: primary.pairingSecret, deviceToken: primary.deviceToken)
			}
			fetchError = nil
		} catch {
			fetchError = error.localizedDescription
		}
	}

	/// Store pairing secret in Keychain for secure access.
	private func storeInKeychain(secret: String, deviceToken: String) throws {
		try setKeychainItem(key: keychainSecretKey, value: secret)
		try setKeychainItem(key: keychainTokenKey, value: deviceToken)
	}

	/// Read stored pairing from Keychain.
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

		let deleteQuery: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: keychainService,
			kSecAttrAccount as String: key,
		]
		SecItemDelete(deleteQuery as CFDictionary)

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
