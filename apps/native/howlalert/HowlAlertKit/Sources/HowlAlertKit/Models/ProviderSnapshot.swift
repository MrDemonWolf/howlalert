import Foundation

public struct ProviderSnapshot {
	public let providerName: String
	public let planName: String
	public let updatedAt: Date
	public let todayCost: Double
	public let todayTokens: Int
	public var rateWindows: [RateWindow]

	public init(
		providerName: String,
		planName: String,
		updatedAt: Date,
		todayCost: Double,
		todayTokens: Int,
		rateWindows: [RateWindow] = []
	) {
		self.providerName = providerName
		self.planName = planName
		self.updatedAt = updatedAt
		self.todayCost = todayCost
		self.todayTokens = todayTokens
		self.rateWindows = rateWindows
	}

	/// The primary rate window (session-level), if available
	public var primary: RateWindow? {
		rateWindows.first(where: { $0.kind == .session })
	}

	/// The weekly rate window, if available
	public var weekly: RateWindow? {
		rateWindows.first(where: { $0.kind == .weekly })
	}
}
