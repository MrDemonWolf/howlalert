import Foundation
import Security

public final class KeychainHelper {
	public static let shared = KeychainHelper()

	private init() {}

	public func save(key: String, value: String) {
		let data = Data(value.utf8)
		let query: [CFString: Any] = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrAccount: key,
			kSecValueData: data,
			kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
		]
		let deleteStatus = SecItemDelete(query as CFDictionary)
		if deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound {
			print("[HowlAlert] Keychain delete warning: \(deleteStatus)")
		}
		let addStatus = SecItemAdd(query as CFDictionary, nil)
		if addStatus != errSecSuccess {
			print("[HowlAlert] Keychain save failed: \(addStatus)")
		}
	}

	public func load(key: String) -> String? {
		let query: [CFString: Any] = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrAccount: key,
			kSecReturnData: true,
			kSecMatchLimit: kSecMatchLimitOne,
		]
		var result: AnyObject?
		guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
			  let data = result as? Data else {
			return nil
		}
		return String(data: data, encoding: .utf8)
	}

	public func delete(key: String) {
		let query: [CFString: Any] = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrAccount: key,
		]
		let status = SecItemDelete(query as CFDictionary)
		if status != errSecSuccess && status != errSecItemNotFound {
			print("[HowlAlert] Keychain delete failed: \(status)")
		}
	}
}
