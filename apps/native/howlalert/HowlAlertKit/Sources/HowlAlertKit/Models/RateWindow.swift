import Foundation

/// Represents a usage rate window (e.g. session, daily, weekly) with capacity and reset timing.
public struct RateWindow: Equatable, Codable, Sendable {
	public let label: String
	public let usedPercent: Double
	public let remainingPercent: Double
	public let resetsAt: Date?
	public let resetDescription: String?

	public init(
		label: String,
		usedPercent: Double,
		remainingPercent: Double,
		resetsAt: Date? = nil,
		resetDescription: String? = nil
	) {
		self.label = label
		self.usedPercent = usedPercent
		self.remainingPercent = remainingPercent
		self.resetsAt = resetsAt
		self.resetDescription = resetDescription
	}

	/// Formatted string for time until reset, e.g. "Resets in 2h 58m"
	public var resetText: String? {
		guard let resetsAt else { return resetDescription }
		let now = Date()
		guard resetsAt > now else { return "Resets soon" }
		let interval = resetsAt.timeIntervalSince(now)
		let hours = Int(interval) / 3600
		let minutes = (Int(interval) % 3600) / 60
		if hours > 24 {
			let days = hours / 24
			let remainingHours = hours % 24
			return "Resets in \(days)d \(remainingHours)h"
		}
		if hours > 0 {
			return "Resets in \(hours)h \(minutes)m"
		}
		return "Resets in \(minutes)m"
	}
}
