import Foundation

public struct DailyUsagePoint: Codable, Sendable, Equatable {
	public let dateString: String  // "2026-03-20"
	public let costUSD: Double
	public let totalTokens: Int

	public init(dateString: String, costUSD: Double, totalTokens: Int) {
		self.dateString = dateString
		self.costUSD = costUSD
		self.totalTokens = totalTokens
	}
}

// MARK: - RateWindow placeholder (HAA-7 will provide the full implementation)

public struct RateWindow: Sendable, Equatable {
	public let name: String
	public let limit: Int
	public let remaining: Int
	public let resetsAt: Date?

	public init(name: String, limit: Int, remaining: Int, resetsAt: Date? = nil) {
		self.name = name
		self.limit = limit
		self.remaining = remaining
		self.resetsAt = resetsAt
	}
}

public struct ProviderSnapshot: Sendable {
	public let provider: String          // "claude"
	public let updatedAt: Date
	public let planName: String

	// Rate windows (from CLI — nil until fetched)
	public let sessionWindow: RateWindow?
	public let weeklyWindow: RateWindow?
	public let modelWindow: RateWindow?

	// Cost data (from JSONL scanner)
	public let todayCostUSD: Double
	public let todayTokens: Int
	public let todaySessionCount: Int
	public let last30DaysCostUSD: Double
	public let last30DaysTokens: Int

	// Daily breakdown for charts
	public let dailyUsage: [DailyUsagePoint]

	public init(
		provider: String = "claude",
		updatedAt: Date = .now,
		planName: String = "Pro",
		sessionWindow: RateWindow? = nil,
		weeklyWindow: RateWindow? = nil,
		modelWindow: RateWindow? = nil,
		todayCostUSD: Double = 0,
		todayTokens: Int = 0,
		todaySessionCount: Int = 0,
		last30DaysCostUSD: Double = 0,
		last30DaysTokens: Int = 0,
		dailyUsage: [DailyUsagePoint] = []
	) {
		self.provider = provider
		self.updatedAt = updatedAt
		self.planName = planName
		self.sessionWindow = sessionWindow
		self.weeklyWindow = weeklyWindow
		self.modelWindow = modelWindow
		self.todayCostUSD = todayCostUSD
		self.todayTokens = todayTokens
		self.todaySessionCount = todaySessionCount
		self.last30DaysCostUSD = last30DaysCostUSD
		self.last30DaysTokens = last30DaysTokens
		self.dailyUsage = dailyUsage
	}
}
