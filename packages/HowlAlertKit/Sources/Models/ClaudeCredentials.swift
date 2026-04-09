import Foundation

/// Decoded from `~/.claude/.credentials.json`
public struct ClaudeCredentials: Decodable {
	public struct OAuthToken: Decodable {
		public let subscriptionType: String?

		enum CodingKeys: String, CodingKey {
			case subscriptionType = "subscription_type"
		}
	}

	public let claudeAiOauth: OAuthToken?

	enum CodingKeys: String, CodingKey {
		case claudeAiOauth = "claudeAiOauth"
	}
}
