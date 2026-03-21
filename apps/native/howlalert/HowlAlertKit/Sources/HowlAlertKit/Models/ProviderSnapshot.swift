import Foundation

/// Unified data model for a provider's usage snapshot, including rate windows and cost data.
public struct ProviderSnapshot: Equatable, Sendable {
	public let providerName: String
	public let planName: String?
	public let updatedAt: Date
	public let primary: RateWindow?
	public let secondary: RateWindow?
	public let primaryPace: UsagePace?
	public let secondaryPace: UsagePace?
	public let todayCost: Double?
	public let todayTokens: Int?
	public let last30DaysCost: Double?
	public let last30DaysTokens: Int?

	public init(
		providerName: String,
		planName: String? = nil,
		updatedAt: Date = Date(),
		primary: RateWindow? = nil,
		secondary: RateWindow? = nil,
		primaryPace: UsagePace? = nil,
		secondaryPace: UsagePace? = nil,
		todayCost: Double? = nil,
		todayTokens: Int? = nil,
		last30DaysCost: Double? = nil,
		last30DaysTokens: Int? = nil
	) {
		self.providerName = providerName
		self.planName = planName
		self.updatedAt = updatedAt
		self.primary = primary
		self.secondary = secondary
		self.primaryPace = primaryPace
		self.secondaryPace = secondaryPace
		self.todayCost = todayCost
		self.todayTokens = todayTokens
		self.last30DaysCost = last30DaysCost
		self.last30DaysTokens = last30DaysTokens
	}
}
