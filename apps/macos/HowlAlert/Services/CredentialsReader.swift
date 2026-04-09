import Foundation

struct ClaudeCredentials: Codable {
	let subscriptionType: String?
	let rateLimitTier: String?

	enum CodingKeys: String, CodingKey {
		case subscriptionType = "subscription_type"
		case rateLimitTier = "rate_limit_tier"
	}
}

/// Reads `~/.claude/.credentials.json` for subscription information.
enum CredentialsReader {

	private static let credentialsPath =
		NSHomeDirectory() + "/.claude/.credentials.json"

	/// Attempts to read and decode the credentials file.
	///
	/// Returns `nil` if the file does not exist, is unreadable, or contains
	/// malformed JSON.
	static func read() -> ClaudeCredentials? {
		let url = URL(fileURLWithPath: credentialsPath)

		guard let data = try? Data(contentsOf: url) else {
			return nil
		}

		let decoder = JSONDecoder()
		return try? decoder.decode(ClaudeCredentials.self, from: data)
	}
}
