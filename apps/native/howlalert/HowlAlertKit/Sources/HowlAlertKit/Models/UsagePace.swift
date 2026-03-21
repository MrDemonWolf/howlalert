import Foundation

public enum PaceStage: String, Sendable {
	case comfortable  // under budget
	case moderate     // slightly over
	case concerning   // significantly over
	case critical     // will definitely run out
}

public struct UsagePace: Sendable, Equatable {
	public let stage: PaceStage
	public let deltaPercent: Double  // positive = over budget, negative = under
	public let etaDescription: String?  // "Runs out in 3d 5h" or nil if comfortable

	public var isInDeficit: Bool { deltaPercent > 0 }

	public var deficitText: String? {
		guard isInDeficit else { return nil }
		return String(format: "%.0f%% in deficit", deltaPercent)
	}

	public static func calculate(usedPercent: Double, windowMinutes: Int, resetsAt: Date) -> UsagePace {
		let now = Date()
		let windowDuration = TimeInterval(windowMinutes * 60)
		let windowStart = resetsAt.addingTimeInterval(-windowDuration)
		let elapsed = now.timeIntervalSince(windowStart)

		guard elapsed > 0, windowDuration > 0 else {
			return UsagePace(stage: .comfortable, deltaPercent: 0, etaDescription: nil)
		}

		let elapsedFraction = min(elapsed / windowDuration, 1.0)
		let expectedPercent = elapsedFraction * 100
		let delta = usedPercent - expectedPercent

		// Determine stage
		let stage: PaceStage
		if delta < 2 { stage = .comfortable }
		else if delta < 6 { stage = .moderate }
		else if delta < 12 { stage = .concerning }
		else { stage = .critical }

		// Calculate ETA (when will we hit 100% at current rate)
		var etaDescription: String? = nil
		if delta > 0, usedPercent > 0, elapsed > 0 {
			let ratePerSecond = usedPercent / elapsed
			let remainingPercent = 100 - usedPercent
			if ratePerSecond > 0 {
				let secondsUntilExhausted = remainingPercent / ratePerSecond
				let remainingInWindow = resetsAt.timeIntervalSince(now)
				if secondsUntilExhausted < remainingInWindow {
					let hours = Int(secondsUntilExhausted) / 3600
					let minutes = (Int(secondsUntilExhausted) % 3600) / 60
					if hours >= 24 {
						let days = hours / 24
						let rh = hours % 24
						etaDescription = "Runs out in \(days)d \(rh)h"
					} else if hours > 0 {
						etaDescription = "Runs out in \(hours)h \(minutes)m"
					} else {
						etaDescription = "Runs out in \(minutes)m"
					}
				}
			}
		}

		return UsagePace(stage: stage, deltaPercent: max(0, delta), etaDescription: etaDescription)
	}
}
