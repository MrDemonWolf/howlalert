import SwiftUI
import HowlAlertKit

struct MenuBarView: View {
	@ObservedObject var coordinator: AlertCoordinator

	private let bgColor = Color(red: 9/255, green: 21/255, blue: 51/255)
	private let accentCyan = Color(red: 15/255, green: 172/255, blue: 237/255)

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			// MARK: - Header
			header
				.padding(.horizontal, 16)
				.padding(.top, 14)
				.padding(.bottom, 10)

			Divider()
				.overlay(Color.white.opacity(0.1))

			// MARK: - Crit Bar
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					Text("\(Int(coordinator.usagePercent))% used")
						.font(.caption)
						.foregroundStyle(.white.opacity(0.7))
					Spacer()
				}
				CritBarView(
					usagePercent: coordinator.usagePercent,
					paceState: coordinator.paceState,
					size: .full
				)
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 10)

			Divider()
				.overlay(Color.white.opacity(0.1))

			// MARK: - Stats Row
			statsRow
				.padding(.horizontal, 16)
				.padding(.vertical, 10)

			Divider()
				.overlay(Color.white.opacity(0.1))

			// MARK: - Model Label
			if let snapshot = coordinator.watcher.currentSnapshot, !snapshot.model.isEmpty {
				Text(snapshot.model)
					.font(.system(.caption, design: .monospaced))
					.foregroundStyle(.white.opacity(0.5))
					.padding(.horizontal, 16)
					.padding(.vertical, 6)

				Divider()
					.overlay(Color.white.opacity(0.1))
			}

			// MARK: - Recent Events
			RecentEventsView(events: Array(coordinator.watcher.recentEvents.suffix(3)))
				.padding(.horizontal, 16)
				.padding(.vertical, 10)

			Divider()
				.overlay(Color.white.opacity(0.1))

			// MARK: - Footer
			footer
				.padding(.horizontal, 16)
				.padding(.vertical, 10)
		}
		.background(bgColor)
		.frame(width: 320)
	}

	// MARK: - Header

	private var header: some View {
		HStack(alignment: .center) {
			Text("HowlAlert")
				.font(.headline)
				.foregroundStyle(.white)

			planBadge(ClaudePlan.detectFromDisk().label)

			Spacer()

			Circle()
				.fill(coordinator.isWatching ? Color.green : Color.red.opacity(0.6))
				.frame(width: 8, height: 8)
		}
	}

	private func planBadge(_ text: String) -> some View {
		Text(text)
			.font(.system(.caption2, design: .rounded, weight: .bold))
			.foregroundStyle(.black)
			.padding(.horizontal, 8)
			.padding(.vertical, 2)
			.background(
				Capsule()
					.fill(accentCyan)
			)
	}

	// MARK: - Stats Row

	private var statsRow: some View {
		HStack(spacing: 0) {
			statItem(
				label: "Tokens",
				value: formattedTokens
			)
			Spacer()
			statItem(
				label: "Sessions",
				value: "\(coordinator.watcher.sessionCount)"
			)
			Spacer()
			statItem(
				label: "Window",
				value: formattedWindowRemaining
			)
		}
	}

	private func statItem(label: String, value: String) -> some View {
		VStack(alignment: .leading, spacing: 2) {
			Text(label)
				.font(.system(.caption2))
				.foregroundStyle(.white.opacity(0.5))
			Text(value)
				.font(.system(.callout, design: .monospaced, weight: .medium))
				.foregroundStyle(.white)
		}
	}

	// MARK: - Footer

	private var footer: some View {
		HStack {
			Button {
				// TODO: Open preferences window
			} label: {
				Label("Preferences", systemImage: "gear")
					.font(.caption)
			}
			.buttonStyle(.plain)
			.foregroundStyle(.white.opacity(0.7))
			.keyboardShortcut(",")

			Spacer()

			Button {
				NSApplication.shared.terminate(nil)
			} label: {
				Text("Quit")
					.font(.caption)
			}
			.buttonStyle(.plain)
			.foregroundStyle(.white.opacity(0.5))
			.keyboardShortcut("q")
		}
	}

	// MARK: - Formatting Helpers

	private var formattedTokens: String {
		guard let snapshot = coordinator.watcher.currentSnapshot else {
			return "0"
		}
		let total = snapshot.totalTokens
		if total >= 1_000_000 {
			return String(format: "%.1fM", Double(total) / 1_000_000)
		} else if total >= 1_000 {
			return String(format: "%.1fK", Double(total) / 1_000)
		}
		return "\(total)"
	}

	private var formattedWindowRemaining: String {
		let remaining = coordinator.windowEnd.timeIntervalSinceNow
		guard remaining > 0 else { return "expired" }

		let totalMinutes = Int(remaining / 60)
		let hours = totalMinutes / 60
		let minutes = totalMinutes % 60

		if hours > 0 {
			return "\(hours)h \(minutes)m left"
		}
		return "\(minutes)m left"
	}
}
