import SwiftUI

/// Main watchOS dashboard showing crit bar and pace status
struct WatchDashboardView: View {
	@ObservedObject var session = WatchSessionManager.shared

	var body: some View {
		ScrollView {
			VStack(spacing: 12) {
				// Usage percentage
				Text("\(Int(session.usagePercent))%")
					.font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())
					.foregroundStyle(critBarColor)

				// Compact crit bar
				GeometryReader { geo in
					ZStack(alignment: .leading) {
						Capsule()
							.fill(Color(red: 0.035, green: 0.082, blue: 0.2))
							.frame(height: 6)

						Capsule()
							.fill(critBarColor)
							.frame(
								width: max(0, geo.size.width * session.usagePercent / 100),
								height: 6
							)
							.animation(.easeInOut(duration: 0.5), value: session.usagePercent)
					}
				}
				.frame(height: 6)

				// Pace indicator
				HStack(spacing: 4) {
					Text(paceArrow)
						.font(.caption)
					Text(paceLabel)
						.font(.caption2)
						.foregroundStyle(.secondary)
				}

				// Model info
				if !session.model.isEmpty {
					Text(session.model)
						.font(.caption2)
						.foregroundStyle(.tertiary)
				}

				// Multiplier badge
				if session.multiplier > 1.0 {
					Text("\(String(format: "%.0f", session.multiplier))x Active")
						.font(.caption2.bold())
						.padding(.horizontal, 8)
						.padding(.vertical, 2)
						.background(Color(red: 0.047, green: 0.678, blue: 0.929).opacity(0.3))
						.clipShape(Capsule())
				}
			}
			.padding()
		}
	}

	private var critBarColor: Color {
		if session.usagePercent < 60 {
			return Color(red: 0.047, green: 0.678, blue: 0.929)  // cyan
		} else if session.usagePercent < 85 {
			return Color(red: 0.961, green: 0.651, blue: 0.137)  // amber
		} else {
			return Color(red: 1.0, green: 0.231, blue: 0.188)    // red
		}
	}

	private var paceArrow: String {
		switch session.paceStatus {
		case "inDebt": return "↓"
		case "inReserve": return "↑"
		default: return "→"
		}
	}

	private var paceLabel: String {
		let pct = Int(abs(session.pacePercent))
		switch session.paceStatus {
		case "inDebt": return "\(pct)% in debt"
		case "inReserve": return "\(pct)% reserve"
		default: return "On track"
		}
	}
}
