import SwiftUI
import HowlAlertKit

/// Demo mode dashboard that cycles through all crit bar and pace states
struct DemoModeView: View {
	@StateObject private var generator = DemoDataGenerator()
	@State private var fakeEvents = DemoDataGenerator.generateFakeEvents()

	var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				// Demo mode banner
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
				.padding(.horizontal)

				// Crit bar (uses percentage directly since CritBarView may not exist yet)
				VStack(spacing: 8) {
					critBarPreview
					paceLabel
				}
				.padding()
				.background(Color(red: 0.035, green: 0.082, blue: 0.2).opacity(0.5))
				.clipShape(RoundedRectangle(cornerRadius: 12))
				.padding(.horizontal)

				// Stats cards
				HStack(spacing: 12) {
					statCard(title: "Tokens Used", value: "\(Int(generator.usagePercent * 1000))K")
					statCard(title: "Sessions", value: "3")
					statCard(title: "Est. Remaining", value: estimatedRemaining)
				}
				.padding(.horizontal)

				// Recent events
				VStack(alignment: .leading, spacing: 8) {
					Text("Recent Events")
						.font(.headline)
						.padding(.horizontal)

					ForEach(fakeEvents) { event in
						HStack {
							VStack(alignment: .leading) {
								Text(event.model)
									.font(.caption.monospaced())
								Text(event.timestamp, style: .relative)
									.font(.caption2)
									.foregroundStyle(.secondary)
							}
							Spacer()
							Text("\(event.totalTokens) tokens")
								.font(.caption.monospacedDigit())
								.foregroundStyle(.secondary)
						}
						.padding(.horizontal)
					}
				}
			}
			.padding(.vertical)
		}
		.navigationTitle("HowlAlert")
		.onAppear { generator.startDemo() }
		.onDisappear { generator.stopDemo() }
	}

	private var critBarPreview: some View {
		GeometryReader { geo in
			ZStack(alignment: .leading) {
				Capsule()
					.fill(Color(red: 0.035, green: 0.082, blue: 0.2))
					.frame(height: 12)

				Capsule()
					.fill(critBarColor)
					.frame(width: max(0, geo.size.width * generator.usagePercent / 100), height: 12)
					.animation(.easeInOut(duration: 0.8), value: generator.usagePercent)
			}
		}
		.frame(height: 12)
	}

	private var critBarColor: Color {
		let state = ThresholdColor.state(for: generator.usagePercent)
		return ThresholdColor.color(for: state)
	}

	private var paceLabel: some View {
		Group {
			if let pace = generator.paceState {
				HStack {
					Circle()
						.fill(paceColor(for: pace.status))
						.frame(width: 6, height: 6)
					Text(paceText(for: pace))
						.font(.caption)
						.foregroundStyle(.secondary)
					Spacer()
				}
			}
		}
	}

	private func paceColor(for status: PaceState.Status) -> Color {
		switch status {
		case .inDebt: return ThresholdColor.limitHit
		case .onTrack: return ThresholdColor.reset
		case .inReserve: return ThresholdColor.ok
		}
	}

	private func paceText(for pace: PaceState) -> String {
		switch pace.status {
		case .inDebt:
			let remaining = pace.estimatedRunout.map { timeRemaining(until: $0) } ?? "unknown"
			return "\(Int(abs(pace.percentDelta)))% in debt · Runs out in \(remaining)"
		case .onTrack:
			return "On track · Lasts until reset"
		case .inReserve:
			return "\(Int(pace.percentDelta))% in reserve · Lasts until reset"
		}
	}

	private func timeRemaining(until date: Date) -> String {
		let seconds = date.timeIntervalSinceNow
		if seconds <= 0 { return "now" }
		let hours = Int(seconds) / 3600
		let minutes = (Int(seconds) % 3600) / 60
		if hours > 0 {
			return "~\(hours)h \(minutes)m"
		}
		return "~\(minutes)m"
	}

	private var estimatedRemaining: String {
		guard let pace = generator.paceState, let runout = pace.estimatedRunout else {
			return "Until reset"
		}
		return timeRemaining(until: runout)
	}

	private func statCard(title: String, value: String) -> some View {
		VStack(spacing: 4) {
			Text(value)
				.font(.title2.bold().monospacedDigit())
			Text(title)
				.font(.caption2)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 12)
		.background(Color(red: 0.035, green: 0.082, blue: 0.2).opacity(0.5))
		.clipShape(RoundedRectangle(cornerRadius: 8))
	}
}
