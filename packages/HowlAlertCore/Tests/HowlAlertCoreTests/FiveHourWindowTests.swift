import Foundation
import Testing
@testable import HowlAlertCore

@Suite("FiveHourWindow")
struct FiveHourWindowTests {
    @Test func groupsCloseEventsIntoOneBlock() {
        let blocks = FiveHourWindow.blocks(from: [
            evt(0, tokens: 100),
            evt(2, tokens: 200),
            evt(4, tokens: 300),
        ])
        #expect(blocks.count == 1)
        #expect(blocks[0].totalTokens == 600)
        #expect(blocks[0].start == hours(0))
        #expect(blocks[0].end == hours(5))
        #expect(blocks[0].lastActivity == hours(4))
        #expect(blocks[0].eventCount == 3)
    }

    @Test func opensNewBlockPastWindowEnd() {
        // 6h is past the first block's end (0h + 5h), even though the gap is < 5h.
        let blocks = FiveHourWindow.blocks(from: [
            evt(0, tokens: 100),
            evt(4, tokens: 100),
            evt(6, tokens: 100),
        ])
        #expect(blocks.count == 2)
        #expect(blocks[0].totalTokens == 200)
        #expect(blocks[1].start == hours(6))
        #expect(blocks[1].totalTokens == 100)
    }

    @Test func opensNewBlockAfterLongGap() {
        // Gap of 7h (> 5h window) splits even though arithmetic windows differ.
        let blocks = FiveHourWindow.blocks(from: [
            evt(0, tokens: 100),
            evt(7, tokens: 100),
        ])
        #expect(blocks.count == 2)
    }

    @Test func currentBlockReturnsActiveWindow() {
        let events = [evt(0, tokens: 100), evt(1, tokens: 100)]
        let block = FiveHourWindow.currentBlock(from: events, now: hours(2))
        #expect(block?.totalTokens == 200)
    }

    @Test func currentBlockNilAfterReset() {
        let events = [evt(0, tokens: 100), evt(1, tokens: 100)]
        // now is past the window end (5h) → window has reset.
        #expect(FiveHourWindow.currentBlock(from: events, now: hours(6)) == nil)
    }

    @Test func completedBlockTotalsExcludesActiveBlock() {
        // Block A [0,5) completed; block B [6,11) active at now=8h.
        let events = [evt(0, tokens: 100), evt(4, tokens: 100), evt(6, tokens: 999)]
        let totals = FiveHourWindow.completedBlockTotals(from: events, now: hours(8))
        #expect(totals == [200])
    }

    @Test func emptyEventsYieldNoBlocks() {
        #expect(FiveHourWindow.blocks(from: []).isEmpty)
        #expect(FiveHourWindow.currentBlock(from: [], now: hours(1)) == nil)
    }
}
