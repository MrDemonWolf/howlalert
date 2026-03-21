import Foundation

/// Scans the Claude configuration directory on macOS to build a UsageState
/// from local conversation data and stats cache.
public struct ConversationScanner {

	/// Scan the Claude directory and return an aggregated UsageState for today.
	public static func scan(from claudeURL: URL) -> UsageState {
		// Try stats-cache.json first
		let statsCacheURL = claudeURL.appendingPathComponent("stats-cache.json")
		if let data = try? Data(contentsOf: statsCacheURL),
		   let cache = try? JSONDecoder().decode(StatsCache.self, from: data) {
			return UsageState(
				dailyCost: cache.totalCost ?? 0,
				totalInputTokens: cache.totalTokens ?? 0,
				totalOutputTokens: 0,
				activeSessions: cache.sessionCount ?? 0,
				lastUpdated: Date(),
				recentEvents: []
			)
		}

		// Fallback: empty state
		return .empty
	}
}
