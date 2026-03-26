import SwiftUI

struct MenuBarView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("HowlAlert")
				.font(.headline)

			Text("Waiting for data...")
				.font(.caption)
				.foregroundStyle(.secondary)

			Divider()

			Button("Preferences...") {
				// TODO: Open preferences window
			}
			.keyboardShortcut(",")

			Button("Quit HowlAlert") {
				NSApplication.shared.terminate(nil)
			}
			.keyboardShortcut("q")
		}
		.padding()
		.frame(width: 280)
	}
}
