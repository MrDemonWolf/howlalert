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

	// MARK: - Running totals

	private var totalInput = 0
	private var totalOutput = 0
	private var totalCacheRead = 0
	private var totalCacheWrite = 0
	private var lastModel = ""
	private var sessionStart: Date?

	// MARK: - Public API

	func addEvent(_ event: JSONLEvent) {
		totalInput += event.inputTokens
		totalOutput += event.outputTokens
		totalCacheRead += event.cacheReadTokens
		totalCacheWrite += event.cacheWriteTokens

		if !event.model.isEmpty {
			lastModel = event.model
		}

		if sessionStart == nil {
			sessionStart = event.timestamp ?? Date()
		}

		snapshot = UsageSnapshot(
			inputTokens: totalInput,
			outputTokens: totalOutput,
			cacheReadTokens: totalCacheRead,
			cacheWriteTokens: totalCacheWrite,
			model: lastModel,
			timestamp: Date(),
			sessionId: nil
		)
	}

	func reset() {
		totalInput = 0
		totalOutput = 0
		totalCacheRead = 0
		totalCacheWrite = 0
		lastModel = ""
		sessionStart = nil
		snapshot = nil
	}
}
