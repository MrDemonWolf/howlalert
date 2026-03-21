import Foundation

public struct RateWindow: Identifiable {
	public enum Kind: String {
		case session
		case weekly
		case model
	}

	public let id: String
	public let kind: Kind
	public let label: String
	public let percentRemaining: Double   // 0.0 to 1.0
	public let resetsAt: Date?
	public let pace: UsagePace?

	public init(
		id: String = UUID().uuidString,
		kind: Kind,
		label: String,
		percentRemaining: Double,
		resetsAt: Date? = nil,
		pace: UsagePace? = nil
	) {
		self.id = id
		self.kind = kind
		self.label = label
		self.percentRemaining = percentRemaining
		self.resetsAt = resetsAt
		self.pace = pace
	}

	/// Percent used (complement of remaining)
	public var percentUsed: Double {
		1.0 - percentRemaining
	}

	/// Human-readable reset countdown
	public var resetText: String? {
		guard let resetsAt = resetsAt else { return nil }
		let interval = resetsAt.timeIntervalSince(Date())
		guard interval > 0 else { return "Resetting..." }

		let hours = Int(interval) / 3600
		let minutes = (Int(interval) % 3600) / 60

		if hours >= 24 {
			let days = hours / 24
			let remainingHours = hours % 24
			return "Resets in \(days)d \(remainingHours)h"
		} else if hours > 0 {
			return "Resets in \(hours)h \(minutes)m"
		} else {
			return "Resets in \(minutes)m"
		}
	}
}
