import SwiftUI

struct ContentView: View {
	@State private var isPaired = false
	@State private var isDemoMode = false

	var body: some View {
		NavigationStack {
			if isPaired || isDemoMode {
				DashboardView(isDemoMode: isDemoMode)
			} else {
				SetupView(isDemoMode: $isDemoMode)
			}
		}
	}
}

struct DashboardView: View {
	let isDemoMode: Bool

	var body: some View {
		ScrollView {
			VStack(spacing: 16) {
				Text(isDemoMode ? "Demo Mode" : "Dashboard")
					.font(.largeTitle.bold())

				Text("Crit bar and usage stats will appear here.")
					.foregroundStyle(.secondary)
			}
			.padding()
		}
		.navigationTitle("HowlAlert")
	}
}

struct SetupView: View {
	@Binding var isDemoMode: Bool

	var body: some View {
		VStack(spacing: 24) {
			Image(systemName: "bell.badge.fill")
				.font(.system(size: 64))
				.foregroundStyle(.cyan)

			Text("Welcome to HowlAlert")
				.font(.title.bold())

			Text("Install HowlAlert on your Mac to start receiving Claude Code usage alerts.")
				.multilineTextAlignment(.center)
				.foregroundStyle(.secondary)

			Button("Try Demo Mode") {
				isDemoMode = true
			}
			.buttonStyle(.borderedProminent)
			.tint(.cyan)
		}
		.padding(32)
	}
}
