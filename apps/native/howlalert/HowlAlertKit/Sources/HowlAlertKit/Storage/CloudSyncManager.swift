import Foundation

/// Manages syncing usage data via iCloud KV store or App Group defaults
/// so iOS/watchOS can display stats collected by macOS.
public final class CloudSyncManager {
	public static let shared = CloudSyncManager()

	private let defaults = UserDefaults(suiteName: "group.com.mrdemonwolf.howlalert") ?? .standard

	private init() {}

	// MARK: - Save (macOS side)

	public func saveUsageState(_ state: UsageState, plan: ClaudePlan) {
		let record = SyncedUsageRecord(
			totalCostUSD: state.dailyCost,
			totalInputTokens: state.totalInputTokens,
			totalOutputTokens: state.totalOutputTokens,
			sessionCount: state.activeSessions,
			planRawValue: plan.rawValue,
			updatedAt: Date()
		)
		if let data = try? JSONEncoder().encode(record) {
			defaults.set(data, forKey: "syncedUsageToday")
		}
	}

	// MARK: - Fetch (iOS/watchOS side)

	public func fetchTodayUsage() -> SyncedUsageRecord? {
		guard let data = defaults.data(forKey: "syncedUsageToday"),
			  let record = try? JSONDecoder().decode(SyncedUsageRecord.self, from: data) else {
			return nil
		}
		// Only return if from today
		guard Calendar.current.isDateInToday(record.updatedAt) else { return nil }
		return record
	}
}

// MARK: - Synced Record

public struct SyncedUsageRecord: Codable {
	public let totalCostUSD: Double
	public let totalInputTokens: Int
	public let totalOutputTokens: Int
	public let sessionCount: Int
	public let planRawValue: String
	public let updatedAt: Date

	public var totalTokens: Int { totalInputTokens + totalOutputTokens }
}
