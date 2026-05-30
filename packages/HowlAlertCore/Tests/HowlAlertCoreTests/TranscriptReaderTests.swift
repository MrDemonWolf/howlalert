import Foundation
import Testing
@testable import HowlAlertCore

@Suite("TranscriptReader")
struct TranscriptReaderTests {
    // MARK: helpers

    func makeRoot() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("howl-\(UUID().uuidString)/projects", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func assistantLine(req: String, tokens: Int = 100) -> String {
        #"{"type":"assistant","timestamp":"2026-05-29T10:00:00.000Z","requestId":"\#(req)","sessionId":"s","isSidechain":false,"message":{"model":"claude-opus-4-7","id":"m_\#(req)","usage":{"input_tokens":\#(tokens),"output_tokens":0}}}"#
    }

    func write(_ lines: [String], to url: URL) throws {
        try (lines.joined(separator: "\n") + "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    func append(_ line: String, to url: URL) throws {
        let h = try FileHandle(forWritingTo: url)
        defer { try? h.close() }
        try h.seekToEnd()
        h.write(Data((line + "\n").utf8))
    }

    // MARK: tests

    @Test func readsAllEventsOnFirstPass() throws {
        let root = try makeRoot()
        let file = root.appendingPathComponent("a.jsonl")
        try write([assistantLine(req: "r1"), assistantLine(req: "r2")], to: file)

        _ = file
        let result = TranscriptReader.read(roots: [root])
        #expect(result.events.count == 2)
        // Cursor fully consumed (file ends with newline).
        #expect(result.cursors.count == 1)
        let cursor = try #require(result.cursors.values.first)
        #expect(cursor.bytesRead == cursor.size)
    }

    @Test func incrementalReadReturnsOnlyNewLines() throws {
        let root = try makeRoot()
        let file = root.appendingPathComponent("a.jsonl")
        try write([assistantLine(req: "r1")], to: file)

        let first = TranscriptReader.read(roots: [root])
        #expect(first.events.count == 1)

        try append(assistantLine(req: "r2"), to: file)
        let second = TranscriptReader.read(roots: [root], cursors: first.cursors)
        #expect(second.events.count == 1)
        #expect(second.events[0].requestId == "r2")
    }

    @Test func noChangeYieldsNoEvents() throws {
        let root = try makeRoot()
        let file = root.appendingPathComponent("a.jsonl")
        try write([assistantLine(req: "r1")], to: file)
        let first = TranscriptReader.read(roots: [root])
        let second = TranscriptReader.read(roots: [root], cursors: first.cursors)
        #expect(second.events.isEmpty)
    }

    @Test func ignoresNonJsonlFiles() throws {
        let root = try makeRoot()
        try write([assistantLine(req: "r1")], to: root.appendingPathComponent("note.txt"))
        try "garbage".write(to: root.appendingPathComponent("data.json"), atomically: true, encoding: .utf8)
        #expect(TranscriptReader.read(roots: [root]).events.isEmpty)
    }

    @Test func subagentPathTagsRole() throws {
        let root = try makeRoot()
        let subDir = root.appendingPathComponent("proj/subagents", isDirectory: true)
        try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true)
        try write([assistantLine(req: "r1")], to: subDir.appendingPathComponent("s.jsonl"))
        let result = TranscriptReader.read(roots: [root])
        #expect(result.events.first?.role == .subagent)
    }

    @Test func modifiedAfterSkipsOldFiles() throws {
        let root = try makeRoot()
        let file = root.appendingPathComponent("old.jsonl")
        try write([assistantLine(req: "r1")], to: file)
        // Backdate the file's mtime.
        let old = Date(timeIntervalSince1970: 1_000_000)
        try FileManager.default.setAttributes([.modificationDate: old], ofItemAtPath: file.path)

        let cutoff = Date(timeIntervalSince1970: 2_000_000)
        #expect(TranscriptReader.read(roots: [root], modifiedAfter: cutoff).events.isEmpty)
    }

    @Test func rereadsFromStartWhenFileShrinks() throws {
        let root = try makeRoot()
        let file = root.appendingPathComponent("a.jsonl")
        try write([assistantLine(req: "r1"), assistantLine(req: "r2")], to: file)
        let first = TranscriptReader.read(roots: [root])
        #expect(first.events.count == 2)

        // Replace with a smaller file (rotation) — should re-read from 0.
        try write([assistantLine(req: "r3")], to: file)
        let second = TranscriptReader.read(roots: [root], cursors: first.cursors)
        #expect(second.events.count == 1)
        #expect(second.events[0].requestId == "r3")
    }
}
