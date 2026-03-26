import SwiftUI
import UserNotifications

/// Custom notification view for usage alerts on watchOS
struct WatchNotificationView: View {
	let usagePercent: Double
	let paceStatus: String
	let pacePercent: Double
	let estimatedRemaining: String?

	var body: some View {
		VStack(spacing: 8) {
			// Crit bar
			GeometryReader { geo in
				ZStack(alignment: .leading) {
					Capsule()
						.fill(Color(red: 0.035, green: 0.082, blue: 0.2))
						.frame(height: 6)

					Capsule()
						.fill(alertColor)
						.frame(
							width: max(0, geo.size.width * usagePercent / 100),
							height: 6
						)
				}
			}
			.frame(height: 6)

			// Usage text
			Text("\(Int(usagePercent))% Used")
				.font(.headline)
				.foregroundStyle(alertColor)

			// Pace label
			Text(paceText)
				.font(.caption2)
				.foregroundStyle(.secondary)

			// Estimated remaining
			if let remaining = estimatedRemaining {
				Text(remaining)
					.font(.caption2.bold())
					.foregroundStyle(paceStatus == "inDebt" ? .red : .green)
			}
		}
		.padding()
	}

	private var alertColor: Color {
		if usagePercent < 60 {
			return Color(red: 0.047, green: 0.678, blue: 0.929)
		} else if usagePercent < 85 {
			return Color(red: 0.961, green: 0.651, blue: 0.137)
		} else {
			return Color(red: 1.0, green: 0.231, blue: 0.188)
		}
	}

	private var paceText: String {
		let pct = Int(abs(pacePercent))
		switch paceStatus {
		case "inDebt": return "\(pct)% in debt · Runs out soon"
		case "inReserve": return "\(pct)% in reserve · Lasts until reset"
		default: return "On track · Lasts until reset"
		}
	}
}
