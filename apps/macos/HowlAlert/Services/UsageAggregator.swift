import Foundation
import HowlAlertKit

/// Aggregates individual ``JSONLEvent`` instances into a running ``UsageSnapshot``.
///
/// Each call to ``addEvent(_:)`` accumulates token counts and updates the
/// published snapshot. Call ``reset()`` to clear all accumulated state.
@MainActor
final class UsageAggregator: ObservableObject {

	// MARK: - Published state

	@Published var snapshot: UsageSnapshot?
	@Published var recentEvents: [JSONLEvent] = []
	@Published var sessionCount: Int = 0

	// MARK: - Running totals

	private var totalInput = 0
	private var totalOutput = 0
	private var totalCacheRead = 0
	private var totalCacheWrite = 0
	private var lastModel = ""
	private var sessionStart: Date?
	private var knownSessionIds: Set<String> = []

	/// Maximum number of recent events to keep for the dashboard.
	private let recentEventLimit = 20

	// MARK: - Public API

	func addEvent(_ event: JSONLEvent) {
		totalInput += event.inputTokens
		totalOutput += event.outputTokens
		totalCacheRead += event.cacheReadTokens
		totalCacheWrite += event.cacheWriteTokens

		if !event.model.isEmpty {
			lastModel = event.model
		}

		let now = Date()
		if sessionStart == nil {
			sessionStart = event.timestamp ?? now
		}

		// Track recent events (keep last N)
		recentEvents.append(event)
		if recentEvents.count > recentEventLimit {
			recentEvents.removeFirst(recentEvents.count - recentEventLimit)
		}

		let sessionTokens = totalInput + totalOutput + totalCacheRead + totalCacheWrite
		snapshot = UsageSnapshot(
			sessionTokens: sessionTokens,
			weeklyTokens: sessionTokens,
			sessionWindowStart: sessionStart ?? now,
			weeklyWindowStart: Calendar.current.startOfDay(for: now),
			model: lastModel,
			capturedAt: now
		)
	}

	/// Increment session count when a new JSONL file is first encountered.
	func trackSession(fileId: String) {
		if knownSessionIds.insert(fileId).inserted {
			sessionCount += 1
		}
	}

	func reset() {
		totalInput = 0
		totalOutput = 0
		totalCacheRead = 0
		totalCacheWrite = 0
		lastModel = ""
		sessionStart = nil
		snapshot = nil
		recentEvents = []
		sessionCount = 0
		knownSessionIds = []
	}
}
