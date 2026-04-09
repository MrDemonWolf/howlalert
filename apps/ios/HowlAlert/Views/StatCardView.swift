import SwiftUI

struct StatCardView: View {
	let title: String
	let value: String
	let trend: Trend?

	enum Trend {
		case up
		case down

		var icon: String {
			switch self {
			case .up: return "arrow.up.right"
			case .down: return "arrow.down.right"
			}
		}

		var color: Color {
			switch self {
			case .up: return .red
			case .down: return .green
			}
		}
	}

	var body: some View {
		VStack(spacing: 4) {
			HStack(spacing: 2) {
				Text(value)
					.font(.title2.bold().monospacedDigit())
					.minimumScaleFactor(0.7)
					.lineLimit(1)
				if let trend {
					Image(systemName: trend.icon)
						.font(.caption2.bold())
						.foregroundStyle(trend.color)
				}
			}
			Text(title)
				.font(.caption2)
				.foregroundStyle(.secondary)
				.lineLimit(1)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 12)
		.padding(.horizontal, 4)
		.background(.regularMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 10))
	}
}
