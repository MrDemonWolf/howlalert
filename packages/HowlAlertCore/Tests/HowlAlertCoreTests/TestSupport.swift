import Foundation
@testable import HowlAlertCore

/// Fixed epoch so date math in tests is deterministic.
let base = Date(timeIntervalSince1970: 1_700_000_000)

func hours(_ h: Double) -> Date { base.addingTimeInterval(h * 3600) }

/// Build a usage event at `hour` offset from `base` with `tokens` input tokens.
func evt(
    _ hour: Double,
    tokens: Int,
    id: String? = nil,
    req: String? = nil,
    role: TranscriptRole = .parent,
    sidechain: Bool = false
) -> UsageEvent {
    UsageEvent(
        timestamp: hours(hour),
        model: "claude-opus-4-7",
        inputTokens: tokens,
        cacheCreationTokens: 0,
        cacheReadTokens: 0,
        outputTokens: 0,
        messageId: id,
        requestId: req,
        sessionId: nil,
        isSidechain: sidechain,
        role: role
    )
}
