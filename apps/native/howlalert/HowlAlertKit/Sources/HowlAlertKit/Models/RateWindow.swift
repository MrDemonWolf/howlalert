import Foundation

public struct RateWindow: Codable, Sendable, Equatable {
	public let usedPercent: Double       // 0-100
	public let windowMinutes: Int?       // e.g. 300 (5h), 10080 (7d)
	public let resetsAt: Date?
	public let resetDescription: String?

	public var remainingPercent: Double { max(0, 100 - usedPercent) }
	public var isExhausted: Bool { usedPercent >= 99.9 }

	public var resetCountdown: String? {
		guard let resetsAt else { return resetDescription }
		let interval = resetsAt.timeIntervalSinceNow
		guard interval > 0 else { return "Resetting..." }
		let hours = Int(interval) / 3600
		let minutes = (Int(interval) % 3600) / 60
		if hours >= 24 {
			let days = hours / 24
			let remainingHours = hours % 24
			return "Resets in \(days)d \(remainingHours)h"
		}
		return "Resets in \(hours)h \(minutes)m"
	}

	public init(usedPercent: Double, windowMinutes: Int? = nil, resetsAt: Date? = nil, resetDescription: String? = nil) {
		self.usedPercent = usedPercent
		self.windowMinutes = windowMinutes
		self.resetsAt = resetsAt
		self.resetDescription = resetDescription
	}
}
