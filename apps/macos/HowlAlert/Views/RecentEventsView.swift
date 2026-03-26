import SwiftUI

/// Compact list of recent JSONL events showing model, token count, and relative timestamp.
struct RecentEventsView: View {
	let events: [JSONLEvent]

	private let accentCyan = Color(red: 15/255, green: 172/255, blue: 237/255)

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text("Recent Events")
				.font(.system(.caption2, weight: .semibold))
				.foregroundStyle(.white.opacity(0.5))
				.textCase(.uppercase)

			if events.isEmpty {
				Text("No events yet")
					.font(.caption)
					.foregroundStyle(.white.opacity(0.3))
					.padding(.vertical, 4)
			} else {
				ForEach(Array(events.reversed().enumerated()), id: \.offset) { _, event in
					eventRow(event)
				}
			}
		}
	}

	private func eventRow(_ event: JSONLEvent) -> some View {
		HStack(spacing: 8) {
			// Model name
			Text(shortModelName(event.model))
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(accentCyan)
				.lineLimit(1)

			Spacer()

			// Token count
			Text(formattedTokens(event.inputTokens + event.outputTokens))
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(.white.opacity(0.8))

			// Relative timestamp
			Text(relativeTime(event.timestamp))
				.font(.caption2)
				.foregroundStyle(.white.opacity(0.4))
				.frame(minWidth: 40, alignment: .trailing)
		}
		.padding(.vertical, 2)
	}

	// MARK: - Formatting

	private func shortModelName(_ model: String) -> String {
		if model.isEmpty { return "unknown" }
		// Strip common prefixes for compact display
		return model
			.replacingOccurrences(of: "claude-", with: "")
	}

	private func formattedTokens(_ total: Int) -> String {
		if total >= 1_000_000 {
			return String(format: "%.1fM", Double(total) / 1_000_000)
		} else if total >= 1_000 {
			return String(format: "%.1fK", Double(total) / 1_000)
		}
		return "\(total)"
	}

	private func relativeTime(_ date: Date?) -> String {
		guard let date else { return "now" }
		let seconds = Int(Date().timeIntervalSince(date))

		if seconds < 60 {
			return "just now"
		} else if seconds < 3600 {
			let minutes = seconds / 60
			return "\(minutes)m ago"
		} else if seconds < 86400 {
			let hours = seconds / 3600
			return "\(hours)h ago"
		} else {
			let days = seconds / 86400
			return "\(days)d ago"
		}
	}
}
