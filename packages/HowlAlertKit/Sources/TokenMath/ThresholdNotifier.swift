import Foundation

/// Determines when to fire local and push notifications based on usage thresholds.
public struct ThresholdNotifier: Sendable {

	public struct ThresholdConfig: Sendable {
		public let alertAt60: Bool
		public let alertAt85: Bool
		public let alertAt100: Bool

		public init(alertAt60: Bool = true, alertAt85: Bool = true, alertAt100: Bool = true) {
			self.alertAt60 = alertAt60
			self.alertAt85 = alertAt85
			self.alertAt100 = alertAt100
		}
	}

	public struct ThresholdEvent: Sendable {
		public let threshold: Double
		public let currentPercent: Double
		public let paceStatus: PaceState.Status
		public let isRateLimit: Bool

		public var title: String {
			if isRateLimit { return "Rate Limited" }
			switch threshold {
			case 100...: return "Limit Hit"
			case 85...: return "Close to Limit"
			default: return "Approaching Limit"
			}
		}

		public var body: String {
			if isRateLimit {
				return "Claude Code rate limit detected at \(Int(currentPercent))% usage."
			}
			return "You've used \(Int(currentPercent))% of your Claude Code limit."
		}

		public var urgency: Urgency {
			if isRateLimit { return .critical }
			switch threshold {
			case 100...: return .critical
			case 85...: return .warning
			default: return .info
			}
		}

		public enum Urgency: Sendable {
			case info
			case warning
			case critical
		}

		public init(
			threshold: Double,
			currentPercent: Double,
			paceStatus: PaceState.Status,
			isRateLimit: Bool
		) {
			self.threshold = threshold
			self.currentPercent = currentPercent
			self.paceStatus = paceStatus
			self.isRateLimit = isRateLimit
		}
	}

	private var firedThresholds: Set<Double> = []

	public init() {}

	/// Check if a threshold was crossed and return event if notification should fire.
	public mutating func check(
		usagePercent: Double,
		paceStatus: PaceState.Status,
		config: ThresholdConfig
	) -> ThresholdEvent? {
		// Check thresholds in descending order so highest crossed wins
		let thresholds: [(Double, Bool)] = [
			(100.0, config.alertAt100),
			(85.0, config.alertAt85),
			(60.0, config.alertAt60),
		]

		for (threshold, enabled) in thresholds {
			if usagePercent >= threshold && enabled && !firedThresholds.contains(threshold) {
				firedThresholds.insert(threshold)
				return ThresholdEvent(
					threshold: threshold,
					currentPercent: usagePercent,
					paceStatus: paceStatus,
					isRateLimit: false
				)
			}
		}

		return nil
	}

	/// Reset when entering a new billing window.
	public mutating func reset() {
		firedThresholds.removeAll()
	}

	/// Force fire for rate limit detection (from Claude Code hook).
	public func rateLimitEvent(usagePercent: Double) -> ThresholdEvent {
		ThresholdEvent(
			threshold: usagePercent,
			currentPercent: usagePercent,
			paceStatus: .inDebt,
			isRateLimit: true
		)
	}
}
