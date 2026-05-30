import Foundation
import Testing
@testable import HowlAlertCore

@Suite("UsageEngine.recentModels")
struct ModelUsageTests {
    func evtModel(_ hour: Double, model: String, tokens: Int, req: String) -> UsageEvent {
        UsageEvent(
            timestamp: hours(hour), model: model,
            inputTokens: tokens, cacheCreationTokens: 0, cacheReadTokens: 0, outputTokens: 0,
            messageId: "m_\(req)", requestId: req
        )
    }

    @Test func aggregatesAndRanksByVolume() {
        let events = [
            evtModel(0, model: "opus", tokens: 100, req: "a"),
            evtModel(1, model: "opus", tokens: 200, req: "b"),
            evtModel(2, model: "sonnet", tokens: 50, req: "c"),
        ]
        let models = UsageEngine.recentModels(events: events, now: hours(3), buckets: 4)
        #expect(models.count == 2)
        #expect(models[0].model == "opus")
        #expect(models[0].totalTokens == 300)
        #expect(models[1].model == "sonnet")
    }

    @Test func limitsToTopN() {
        let events = (0..<5).map { evtModel(Double($0) * 0.1, model: "m\($0)", tokens: (5 - $0) * 100, req: "r\($0)") }
        let models = UsageEngine.recentModels(events: events, now: hours(1), top: 3)
        #expect(models.count == 3)
        #expect(models.map(\.model) == ["m0", "m1", "m2"]) // highest volume first
    }

    @Test func excludesEventsOutsideSpan() {
        let events = [
            evtModel(0, model: "old", tokens: 999, req: "a"),     // 10h before now
            evtModel(9, model: "recent", tokens: 100, req: "b"),
        ]
        let models = UsageEngine.recentModels(events: events, now: hours(10), span: 5 * 3600)
        #expect(models.count == 1)
        #expect(models[0].model == "recent")
    }

    @Test func sparklineHasBucketCountAndSumsToTotal() {
        let events = [
            evtModel(0, model: "opus", tokens: 100, req: "a"),
            evtModel(4, model: "opus", tokens: 300, req: "b"),
        ]
        let models = UsageEngine.recentModels(events: events, now: hours(5), span: 5 * 3600, buckets: 5)
        let opus = try! #require(models.first)
        #expect(opus.sparkline.count == 5)
        #expect(opus.sparkline.reduce(0, +) == 400)
    }

    @Test func emptyWhenNoRecentEvents() {
        #expect(UsageEngine.recentModels(events: [], now: hours(1)).isEmpty)
    }
}
