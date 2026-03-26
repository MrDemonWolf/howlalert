import SwiftUI

struct WatchContentView: View {
	var body: some View {
		VStack(spacing: 8) {
			Text("HowlAlert")
				.font(.headline)

			// Crit bar placeholder
			RoundedRectangle(cornerRadius: 4)
				.fill(Color(red: 0.047, green: 0.678, blue: 0.929))
				.frame(height: 8)

			Text("Waiting for data")
				.font(.caption2)
				.foregroundStyle(.secondary)
		}
		.padding()
	}
}
