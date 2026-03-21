import Foundation

/// Scans Claude JSONL conversation logs to extract usage statistics.
///
/// Claude stores hook event logs as JSONL files under `~/.claude/projects/<encoded-path>/`.
/// Each line is a JSON object matching the `HookEvent` schema (session_id, model, tokens, cost_usd, etc.).
public struct ConversationScanner {

	// MARK: - Public API

	/// Scan JSONL files for today's usage and return a `UsageState`.
	public static func scan(from claudeDirectoryURL: URL) -> UsageState {
		let today = dateString(for: .now)
		let events = parseAllEvents(from: claudeDirectoryURL)

		let todayEvents = events.filter { dateString(for: $0.timestamp) == today }

		let dailyCost = todayEvents.reduce(0.0) { $0 + $1.costUSD }
		let totalInput = todayEvents.reduce(0) { $0 + $1.inputTokens }
		let totalOutput = todayEvents.reduce(0) { $0 + $1.outputTokens }
		let sessionIds = Set(todayEvents.map(\.sessionId))

		return UsageState(
			dailyCost: dailyCost,
			totalInputTokens: totalInput,
			totalOutputTokens: totalOutput,
			activeSessions: sessionIds.count,
			lastUpdated: .now,
			recentEvents: Array(todayEvents.suffix(20))
		)
	}

	/// Scan JSONL files and return per-day usage for the last N days.
	public static func scanHistory(from claudeDirectoryURL: URL, days: Int = 30) -> [DailyUsagePoint] {
		let calendar = Calendar.current
		let now = Date.now
		guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: calendar.startOfDay(for: now)) else {
			return []
		}

		let events = parseAllEvents(from: claudeDirectoryURL)

		// Filter to events within the date range
		let rangeEvents = events.filter { $0.timestamp >= cutoffDate }

		// Group by date string
		var buckets: [String: (cost: Double, tokens: Int)] = [:]
		for event in rangeEvents {
			let key = dateString(for: event.timestamp)
			let existing = buckets[key, default: (cost: 0, tokens: 0)]
			buckets[key] = (
				cost: existing.cost + event.costUSD,
				tokens: existing.tokens + event.inputTokens + event.outputTokens
			)
		}

		// Build sorted array
		return buckets
			.map { DailyUsagePoint(dateString: $0.key, costUSD: $0.value.cost, totalTokens: $0.value.tokens) }
			.sorted { $0.dateString < $1.dateString }
	}

	// MARK: - Internal helpers

	/// Parse all JSONL files under the given directory into `UsageEvent` values.
	private static func parseAllEvents(from directoryURL: URL) -> [UsageEvent] {
		let fm = FileManager.default
		guard fm.fileExists(atPath: directoryURL.path) else { return [] }

		// Find all .jsonl files recursively
		guard let enumerator = fm.enumerator(
			at: directoryURL,
			includingPropertiesForKeys: [.isRegularFileKey],
			options: [.skipsHiddenFiles]
		) else { return [] }

		var events: [UsageEvent] = []
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601

		for case let fileURL as URL in enumerator {
			guard fileURL.pathExtension == "jsonl" else { continue }
			guard let data = try? Data(contentsOf: fileURL),
				  let content = String(data: data, encoding: .utf8) else { continue }

			let lines = content.components(separatedBy: .newlines)
			for line in lines {
				let trimmed = line.trimmingCharacters(in: .whitespaces)
				guard !trimmed.isEmpty,
					  let lineData = trimmed.data(using: .utf8) else { continue }

				// Try parsing as HookEvent first, then convert to UsageEvent
				if let hookEvent = try? decoder.decode(HookEvent.self, from: lineData),
				   let usageEvent = hookEvent.toUsageEvent() {
					events.append(usageEvent)
				}
			}
		}

		return events
	}

	/// Format a date as "yyyy-MM-dd" in the current calendar's time zone.
	private static func dateString(for date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter.string(from: date)
	}

	/// Returns the default Claude projects directory URL (macOS only).
	public static func defaultClaudeDirectoryURL() -> URL? {
		#if os(macOS)
		return FileManager.default.homeDirectoryForCurrentUser
			.appendingPathComponent(".claude/projects", isDirectory: true)
		#else
		return nil
		#endif
	}
}
