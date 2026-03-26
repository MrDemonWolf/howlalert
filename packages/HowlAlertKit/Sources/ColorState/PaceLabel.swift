import SwiftUI

public struct PaceLabel: View {
	public let paceState: PaceState

	public init(paceState: PaceState) {
		self.paceState = paceState
	}

	public var body: some View {
		Text(labelText)
			.foregroundStyle(labelColor)
	}

	private var labelText: String {
		switch paceState.status {
		case .inDebt:
			let pct = Int(abs(paceState.percentDelta).rounded())
			let runout = formattedRunout
			return "\(pct)% in debt · Runs out in \(runout)"
		case .onTrack:
			return "On track · Lasts until reset"
		case .inReserve:
			let pct = Int(paceState.percentDelta.rounded())
			return "\(pct)% in reserve · Lasts until reset"
		}
	}

	private var labelColor: Color {
		switch paceState.status {
		case .inDebt:
			return ThresholdColor.limitHit
		case .onTrack:
			return ThresholdColor.reset
		case .inReserve:
			return ThresholdColor.ok
		}
	}

	private var formattedRunout: String {
		guard let runout = paceState.estimatedRunout else {
			return "—"
		}
		let interval = runout.timeIntervalSinceNow
		guard interval > 0 else { return "now" }

		let totalMinutes = Int(interval / 60)
		let hours = totalMinutes / 60
		let minutes = totalMinutes % 60

		if hours > 0 {
			return "~\(hours)h \(minutes)m"
		}
		return "~\(minutes)m"
	}
}
