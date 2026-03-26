import Foundation

public struct PaceState: Codable, Sendable, Equatable {
	public enum Status: String, Codable, Sendable {
		case inDebt
		case onTrack
		case inReserve
	}

	public let status: Status
	public let percentDelta: Double
	public let estimatedRunout: Date?
	public let windowResetDate: Date

	public init(status: Status, percentDelta: Double, estimatedRunout: Date?, windowResetDate: Date) {
		self.status = status
		self.percentDelta = percentDelta
		self.estimatedRunout = estimatedRunout
		self.windowResetDate = windowResetDate
	}
}

public func calculatePace(
	consumed: Int,
	limit: Int,
	windowStart: Date,
	windowEnd: Date,
	now: Date,
	multiplier: Double = 1.0
) -> PaceState {
	let effectiveLimit = Double(limit) * multiplier
	let windowDuration = windowEnd.timeIntervalSince(windowStart)
	let elapsed = now.timeIntervalSince(windowStart)

	// Too early in the window to make a meaningful calculation
	if elapsed / windowDuration < 0.03 {
		return PaceState(
			status: .onTrack,
			percentDelta: 0.0,
			estimatedRunout: nil,
			windowResetDate: windowEnd
		)
	}

	let evenRate = effectiveLimit / windowDuration
	let actualRate = Double(consumed) / elapsed
	let percentDelta = ((evenRate - actualRate) / evenRate) * 100.0

	if abs(percentDelta) <= 5.0 {
		return PaceState(
			status: .onTrack,
			percentDelta: percentDelta,
			estimatedRunout: nil,
			windowResetDate: windowEnd
		)
	}

	if percentDelta > 5.0 {
		return PaceState(
			status: .inReserve,
			percentDelta: percentDelta,
			estimatedRunout: nil,
			windowResetDate: windowEnd
		)
	}

	// In debt — calculate estimated runout
	let remaining = effectiveLimit - Double(consumed)
	var estimatedRunout: Date? = nil
	if actualRate > 0 && remaining > 0 {
		estimatedRunout = now.addingTimeInterval(remaining / actualRate)
	}

	return PaceState(
		status: .inDebt,
		percentDelta: percentDelta,
		estimatedRunout: estimatedRunout,
		windowResetDate: windowEnd
	)
}
