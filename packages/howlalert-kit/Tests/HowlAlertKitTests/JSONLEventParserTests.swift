import Testing
import Foundation
@testable import HowlAlertKit

@Suite("JSONLEventParser")
struct JSONLEventParserTests {
    @Test("parses an assistant turn with model + fractional ISO timestamp")
    func assistantTurnWithModel() {
        let line = #"{"type":"assistant","timestamp":"2026-05-18T14:37:22.512Z","message":{"model":"claude-sonnet-4-6","role":"assistant"}}"#
        let event = JSONLEventParser.parseLine(line)
        #expect(event?.model == "claude-sonnet-4-6")
        #expect(event != nil)
    }

    @Test("parses plain ISO timestamp without fractional seconds")
    func plainISO() {
        let line = #"{"type":"assistant","timestamp":"2026-05-18T14:37:22Z","model":"opus"}"#
        let event = JSONLEventParser.parseLine(line)
        #expect(event?.model == "opus")
    }

    @Test("skips non-assistant turns")
    func skipsUser() {
        let line = #"{"type":"user","timestamp":"2026-05-18T14:37:22Z"}"#
        #expect(JSONLEventParser.parseLine(line) == nil)
    }

    @Test("returns nil for malformed JSON instead of throwing")
    func tolerantOfGarbage() {
        #expect(JSONLEventParser.parseLine("not json at all") == nil)
        #expect(JSONLEventParser.parseLine("") == nil)
        #expect(JSONLEventParser.parseLine(#"{"timestamp":"oops"}"#) == nil)
    }

    @Test("parses a chunk of multiple lines and skips bad ones")
    func chunkSkipsBadLines() {
        let chunk = """
        {"type":"assistant","timestamp":"2026-05-18T14:00:00Z","model":"a"}
        garbage line
        {"type":"user","timestamp":"2026-05-18T14:01:00Z"}
        {"type":"assistant","timestamp":"2026-05-18T14:02:00Z","model":"b"}
        """
        let events = JSONLEventParser.parse(chunk: chunk)
        #expect(events.count == 2)
        #expect(events.map(\.model) == ["a", "b"])
    }
}
