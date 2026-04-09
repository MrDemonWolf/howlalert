import SwiftUI

struct UsageHistoryView: View {
	let events: [FakeUsageEvent]

	private var groupedEvents: [(String, [FakeUsageEvent])] {
		let calendar = Calendar.current
		var today: [FakeUsageEvent] = []
		var yesterday: [FakeUsageEvent] = []
		var older: [FakeUsageEvent] = []

		for event in events {
			if calendar.isDateInToday(event.timestamp) {
				today.append(event)
			} else if calendar.isDateInYesterday(event.timestamp) {
				yesterday.append(event)
			} else {
				older.append(event)
			}
		}

		var groups: [(String, [FakeUsageEvent])] = []
		if !today.isEmpty { groups.append(("Today", today)) }
		if !yesterday.isEmpty { groups.append(("Yesterday", yesterday)) }
		if !older.isEmpty { groups.append(("Earlier", older)) }
		return groups
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Usage History")
				.font(.headline)

			if events.isEmpty {
				emptyState
			} else {
				ForEach(groupedEvents, id: \.0) { section in
					sectionView(title: section.0, events: section.1)
				}
			}
		}
	}

	private var emptyState: some View {
		VStack(spacing: 8) {
			Image(systemName: "clock")
				.font(.title2)
				.foregroundStyle(.secondary)
			Text("No recent events")
				.font(.subheadline)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 24)
	}

	private func sectionView(title: String, events: [FakeUsageEvent]) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(title)
				.font(.caption.bold())
				.foregroundStyle(.secondary)
				.textCase(.uppercase)

			ForEach(events) { event in
				eventRow(event)
			}
		}
	}

	private func eventRow(_ event: FakeUsageEvent) -> some View {
		HStack(spacing: 12) {
			modelIcon(for: event.model)
				.frame(width: 32, height: 32)
				.background(.regularMaterial)
				.clipShape(RoundedRectangle(cornerRadius: 6))

			VStack(alignment: .leading, spacing: 2) {
				Text(event.model)
					.font(.caption.monospaced())
					.lineLimit(1)
				Text(event.timestamp, style: .relative)
					.font(.caption2)
					.foregroundStyle(.secondary)
			}

			Spacer()

			Text(formattedTokens(event.totalTokens))
				.font(.caption.monospacedDigit())
				.foregroundStyle(.secondary)
		}
		.padding(.vertical, 4)
	}

	private func modelIcon(for model: String) -> some View {
		Group {
			if model.contains("opus") {
				Image(systemName: "diamond.fill")
					.foregroundStyle(.purple)
			} else if model.contains("sonnet") {
				Image(systemName: "music.note")
					.foregroundStyle(.blue)
			} else {
				Image(systemName: "hare.fill")
					.foregroundStyle(.green)
			}
		}
		.font(.caption)
	}

	private func formattedTokens(_ count: Int) -> String {
		if count >= 1000 {
			return String(format: "%.1fK", Double(count) / 1000)
		}
		return "\(count)"
	}
}
