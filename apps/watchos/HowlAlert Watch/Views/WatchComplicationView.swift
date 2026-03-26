import SwiftUI

struct WatchComplicationView: View {
	var usagePercent: Double = 0
	var paceArrow: String = "→"

	var body: some View {
		HStack(spacing: 4) {
			Text("\(Int(usagePercent))%")
				.font(.caption.monospacedDigit())
			Text(paceArrow)
				.font(.caption2)
		}
	}
}
