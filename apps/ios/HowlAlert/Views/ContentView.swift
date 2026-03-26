import SwiftUI
import HowlAlertKit

struct ContentView: View {
	@StateObject private var pairingManager = PairingManager()
	@State private var isDemoMode = false

	var body: some View {
		NavigationStack {
			if pairingManager.isPaired || isDemoMode {
				DashboardView(
					pairingManager: pairingManager,
					isDemoMode: $isDemoMode
				)
			} else {
				SetupView(isDemoMode: $isDemoMode)
			}
		}
	}
}

// MARK: - DashboardView

struct DashboardView: View {
	@ObservedObject var pairingManager: PairingManager
	@Binding var isDemoMode: Bool
	@StateObject private var generator = DemoDataGenerator()
	@State private var showPreferences = false
	@State private var fakeEvents = DemoDataGenerator.generateFakeEvents()

	private let accentCyan = Color(red: 0.059, green: 0.678, blue: 0.929) // #0FACED

	var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				// Demo mode banner
				if isDemoMode {
					demoBanner
				}

				// Crit Bar card
				critBarCard

				// Usage stats
				statsRow

				// Multiplier banner
				if let pace = generator.paceState, multiplierValue(pace) > 1.0 {
					multiplierBanner(multiplierValue(pace))
				}

				// Usage history
				UsageHistoryView(events: fakeEvents)
			}
			.padding()
		}
		.refreshable {
			await refreshData()
		}
		.navigationTitle("HowlAlert")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					showPreferences = true
				} label: {
					Image(systemName: "gearshape")
						.foregroundStyle(accentCyan)
				}
			}
		}
		.sheet(isPresented: $showPreferences) {
			PreferencesView()
		}
		.onAppear {
			if isDemoMode {
				generator.startDemo()
			}
		}
		.onDisappear {
			generator.stopDemo()
		}
	}

	// MARK: - Demo Banner

	private var demoBanner: some View {
		HStack {
			Image(systemName: "play.circle.fill")
				.foregroundStyle(.orange)
			Text("Demo Mode")
				.font(.caption.bold())
				.foregroundStyle(.orange)
			Spacer()
			Text(generator.currentState.displayName)
				.font(.caption)
				.foregroundStyle(.secondary)
		}
		.padding(.horizontal, 12)
		.padding(.vertical, 8)
		.background(Color.orange.opacity(0.1))
		.clipShape(RoundedRectangle(cornerRadius: 8))
	}

	// MARK: - Crit Bar Card

	private var critBarCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text("Usage")
					.font(.headline)
				Spacer()
				Text("\(Int(generator.usagePercent))%")
					.font(.title3.bold().monospacedDigit())
					.foregroundStyle(accentCyan)
			}

			CritBarView(
				usagePercent: generator.usagePercent,
				paceState: generator.paceState,
				size: .full
			)
		}
		.padding()
		.background(.regularMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 12))
	}

	// MARK: - Stats Row

	private var statsRow: some View {
		HStack(spacing: 12) {
			StatCardView(
				title: "Tokens Used",
				value: formattedTokens,
				trend: tokenTrend
			)
			StatCardView(
				title: "Sessions",
				value: "3",
				trend: nil
			)
			StatCardView(
				title: "Time Left",
				value: estimatedRemaining,
				trend: nil
			)
		}
	}

	// MARK: - Multiplier Banner

	private func multiplierBanner(_ multiplier: Double) -> some View {
		HStack {
			Image(systemName: "bolt.fill")
				.foregroundStyle(accentCyan)
			Text("\(Int(multiplier))x Limit Active")
				.font(.subheadline.bold())
				.foregroundStyle(accentCyan)
			Spacer()
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 10)
		.background(accentCyan.opacity(0.12))
		.clipShape(RoundedRectangle(cornerRadius: 8))
	}

	// MARK: - Helpers

	private var formattedTokens: String {
		let tokens = generator.usagePercent * 1000
		if tokens >= 1000 {
			return String(format: "%.1fM", tokens / 1000)
		}
		return String(format: "%.1fK", tokens)
	}

	private var tokenTrend: StatCardView.Trend? {
		guard let pace = generator.paceState else { return nil }
		switch pace.status {
		case .inDebt: return .up
		case .inReserve: return .down
		case .onTrack: return nil
		}
	}

	private var estimatedRemaining: String {
		guard let pace = generator.paceState, let runout = pace.estimatedRunout else {
			return "-- --"
		}
		let seconds = runout.timeIntervalSinceNow
		if seconds <= 0 { return "0m" }
		let hours = Int(seconds) / 3600
		let minutes = (Int(seconds) % 3600) / 60
		if hours > 0 {
			return "\(hours)h \(minutes)m"
		}
		return "\(minutes)m"
	}

	private func multiplierValue(_ pace: PaceState) -> Double {
		// In real implementation this comes from user preferences
		// For demo, show multiplier when in reserve state
		if pace.status == .inReserve { return 2.0 }
		return 1.0
	}

	private func refreshData() async {
		// Simulate network refresh
		try? await Task.sleep(nanoseconds: 500_000_000)
		if isDemoMode {
			fakeEvents = DemoDataGenerator.generateFakeEvents()
		}
	}
}

// MARK: - SetupView

struct SetupView: View {
	@Binding var isDemoMode: Bool

	private let accentCyan = Color(red: 0.059, green: 0.678, blue: 0.929)

	var body: some View {
		VStack(spacing: 24) {
			Spacer()

			Image(systemName: "bell.badge.fill")
				.font(.system(size: 64))
				.foregroundStyle(accentCyan)

			Text("Welcome to HowlAlert")
				.font(.title.bold())

			Text("Install HowlAlert on your Mac to start receiving Claude Code usage alerts.")
				.multilineTextAlignment(.center)
				.foregroundStyle(.secondary)

			Button("Try Demo Mode") {
				isDemoMode = true
			}
			.buttonStyle(.borderedProminent)
			.tint(accentCyan)

			Spacer()
		}
		.padding(32)
	}
}
