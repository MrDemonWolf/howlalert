import XCTest
@testable import HowlAlertKit

final class HowlAlertKitTests: XCTestCase {
    func testUsageEventCodable() throws {
        let event = UsageEvent(
            sessionId: "test-session",
            model: "claude-opus-4-6",
            inputTokens: 100,
            outputTokens: 50,
            costUSD: 0.01
        )
        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(UsageEvent.self, from: data)
        XCTAssertEqual(decoded.sessionId, event.sessionId)
        XCTAssertEqual(decoded.costUSD, event.costUSD)
        XCTAssertEqual(decoded.inputTokens, 100)
    }

    func testHookEventParsing() throws {
        let json = """
        {"session_id":"abc","tool_name":"Bash","model":"claude-opus-4-6","input_tokens":100,"output_tokens":50,"cost_usd":0.01}
        """.data(using: .utf8)!
        let event = try HookEventParser.parse(from: json)
        XCTAssertEqual(event.sessionId, "abc")
        XCTAssertEqual(event.costUSD, 0.01)
        let usage = event.toUsageEvent()
        XCTAssertNotNil(usage)
        XCTAssertEqual(usage?.costUSD, 0.01)
        XCTAssertEqual(usage?.model, "claude-opus-4-6")
    }

    func testHookEventMissingCostReturnsNil() throws {
        let json = """
        {"session_id":"abc","tool_name":"Read"}
        """.data(using: .utf8)!
        let event = try HookEventParser.parse(from: json)
        XCTAssertNil(event.toUsageEvent())
    }

    func testAlertThresholdDefaults() {
        XCTAssertFalse(AlertThreshold.defaults.isEmpty)
        XCTAssertNotNil(AlertThreshold.defaults.first(where: { $0.type == .dailyCost }))
        XCTAssertEqual(AlertThreshold.defaults.first(where: { $0.type == .dailyCost })?.value, 5.0)
    }

    func testStatsCacheParsing() throws {
        let json = """
        {"total_cost": 3.50, "total_tokens": 75000, "session_count": 5}
        """.data(using: .utf8)!
        let cache = try JSONDecoder().decode(StatsCache.self, from: json)
        XCTAssertEqual(cache.totalCost, 3.50)
        XCTAssertEqual(cache.sessionCount, 5)
        XCTAssertEqual(cache.totalTokens, 75000)
    }

    func testUsageStateEmpty() {
        XCTAssertEqual(UsageState.empty.dailyCost, 0)
        XCTAssertEqual(UsageState.empty.totalTokens, 0)
        XCTAssertTrue(UsageState.empty.recentEvents.isEmpty)
    }
}
