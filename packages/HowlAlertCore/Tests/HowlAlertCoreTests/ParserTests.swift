import Foundation
import Testing
@testable import HowlAlertCore

@Suite("ClaudeTranscriptParser")
struct ParserTests {
    static let validLine = #"""
    {"type":"assistant","timestamp":"2026-05-29T10:00:00.000Z","requestId":"req_1","sessionId":"sess_1","isSidechain":false,"message":{"model":"claude-opus-4-7","id":"msg_1","usage":{"input_tokens":100,"cache_creation_input_tokens":20,"cache_read_input_tokens":5,"output_tokens":50}}}
    """#

    @Test func parsesValidLine() throws {
        let e = try #require(ClaudeTranscriptParser.parseLine(Self.validLine))
        #expect(e.inputTokens == 100)
        #expect(e.cacheCreationTokens == 20)
        #expect(e.cacheReadTokens == 5)
        #expect(e.outputTokens == 50)
        #expect(e.totalTokens == 175)
        #expect(e.model == "claude-opus-4-7")
        #expect(e.messageId == "msg_1")
        #expect(e.requestId == "req_1")
        #expect(e.dedupeKey == "msg_1:req_1")
    }

    @Test func rejectsNonUsageLine() {
        let line = #"{"type":"user","message":{"role":"user","content":"hi"}}"#
        #expect(ClaudeTranscriptParser.parseLine(line) == nil)
    }

    @Test func rejectsMalformedJSON() {
        let line = #"{"type":"assistant","usage": broken"#
        #expect(ClaudeTranscriptParser.parseLine(line) == nil)
    }

    @Test func rejectsAllZeroRow() {
        let line = #"""
        {"type":"assistant","timestamp":"2026-05-29T10:00:00Z","message":{"model":"m","id":"x","usage":{"input_tokens":0,"cache_creation_input_tokens":0,"cache_read_input_tokens":0,"output_tokens":0}}}
        """#
        #expect(ClaudeTranscriptParser.parseLine(line) == nil)
    }

    @Test func parsesTimestampWithAndWithoutFractionalSeconds() {
        #expect(ClaudeTranscriptParser.parseTimestamp("2026-05-29T10:00:00.123Z") != nil)
        #expect(ClaudeTranscriptParser.parseTimestamp("2026-05-29T10:00:00Z") != nil)
        #expect(ClaudeTranscriptParser.parseTimestamp("not-a-date") == nil)
    }

    @Test func dedupeKeepsLastChunkForSameKey() {
        // Streaming chunks: same key, cumulative totals — final chunk wins.
        let first = evt(0, tokens: 100, id: "m", req: "r")
        let final = evt(0, tokens: 175, id: "m", req: "r")
        let out = ClaudeTranscriptParser.deduped([first, final])
        #expect(out.count == 1)
        #expect(out[0].totalTokens == 175)
    }

    @Test func dedupeKeepsUnkeyedRows() {
        let a = evt(0, tokens: 10) // no ids
        let b = evt(1, tokens: 20)
        #expect(ClaudeTranscriptParser.deduped([a, b]).count == 2)
    }

    @Test func dedupeParentBeatsSubagentRegardlessOfOrder() {
        let parent = evt(0, tokens: 200, id: "m", req: "r", role: .parent)
        let sub = evt(0, tokens: 200, id: "m", req: "r", role: .subagent)
        #expect(ClaudeTranscriptParser.deduped([sub, parent])[0].role == .parent)
        #expect(ClaudeTranscriptParser.deduped([parent, sub])[0].role == .parent)
    }

    @Test func dedupeNonSidechainBeatsSidechain() {
        let main = evt(0, tokens: 200, id: "m", req: "r", sidechain: false)
        let side = evt(0, tokens: 200, id: "m", req: "r", sidechain: true)
        #expect(ClaudeTranscriptParser.deduped([side, main])[0].isSidechain == false)
    }

    @Test func parsesMultiLineContents() {
        let contents = Self.validLine + "\n" + #"{"type":"user","message":{}}"# + "\n" + Self.validLine
        #expect(ClaudeTranscriptParser.parse(contents: contents).count == 2)
    }
}
