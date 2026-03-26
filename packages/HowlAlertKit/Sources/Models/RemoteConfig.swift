import Foundation

public struct RemoteConfig: Codable, Sendable {
	public let multiplier: Double
	public let activeFrom: Date?
	public let activeUntil: Date?
	public let offPeakOnly: Bool
	public let offPeakWindows: OffPeakWindows?
	public let reason: String
	public let updatedAt: Date
	public let plans: [String: PlanLimits]?

	public init(
		multiplier: Double,
		activeFrom: Date?,
		activeUntil: Date?,
		offPeakOnly: Bool,
		offPeakWindows: OffPeakWindows?,
		reason: String,
		updatedAt: Date,
		plans: [String: PlanLimits]?
	) {
		self.multiplier = multiplier
		self.activeFrom = activeFrom
		self.activeUntil = activeUntil
		self.offPeakOnly = offPeakOnly
		self.offPeakWindows = offPeakWindows
		self.reason = reason
		self.updatedAt = updatedAt
		self.plans = plans
	}

	public struct OffPeakWindows: Codable, Sendable {
		public let weekday: [TimeWindow]?
		public let weekend: String?

		public init(weekday: [TimeWindow]?, weekend: String?) {
			self.weekday = weekday
			self.weekend = weekend
		}
	}

	public struct TimeWindow: Codable, Sendable {
		public let startUTC: Int
		public let endUTC: Int

		public init(startUTC: Int, endUTC: Int) {
			self.startUTC = startUTC
			self.endUTC = endUTC
		}
	}

	public struct PlanLimits: Codable, Sendable {
		public let sessionLimit: Int?
		public let weeklyLimit: Int?

		public init(sessionLimit: Int?, weeklyLimit: Int?) {
			self.sessionLimit = sessionLimit
			self.weeklyLimit = weeklyLimit
		}
	}
}
