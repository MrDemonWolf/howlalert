import Foundation

/// Per-file read position, so we only parse newly-appended bytes on each pass.
public struct FileCursor: Sendable, Equatable {
    /// Bytes consumed so far (always ends on a line boundary).
    public var bytesRead: Int
    /// File size at the last read (used to detect growth / truncation).
    public var size: Int

    public init(bytesRead: Int = 0, size: Int = 0) {
        self.bytesRead = bytesRead
        self.size = size
    }
}

/// Events parsed this pass plus the advanced cursors to carry into the next.
public struct TranscriptReadResult: Sendable {
    public var events: [UsageEvent]
    public var cursors: [String: FileCursor]

    public init(events: [UsageEvent], cursors: [String: FileCursor]) {
        self.events = events
        self.cursors = cursors
    }
}

/// Reads `*.jsonl` transcripts under the discovered roots, incrementally.
///
/// Append-only files (Claude transcripts) are read from the last cursor offset
/// forward; only complete lines (through the final `\n`) are consumed, so a
/// half-written trailing line is re-read once it's finished. A file that shrank
/// (rotated/replaced) is re-read from the start.
public enum TranscriptReader {
    public static func read(
        roots: [URL],
        cursors: [String: FileCursor] = [:],
        modifiedAfter: Date? = nil,
        fileManager: FileManager = .default
    ) -> TranscriptReadResult {
        var newCursors = cursors
        var events: [UsageEvent] = []
        let keys: [URLResourceKey] = [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey]

        for root in roots {
            guard let enumerator = fileManager.enumerator(
                at: root,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { continue }

            for case let url as URL in enumerator {
                guard url.pathExtension == "jsonl" else { continue }
                let values = try? url.resourceValues(forKeys: Set(keys))
                let size = values?.fileSize ?? 0
                guard size > 0 else { continue }
                if let cutoff = modifiedAfter, let mtime = values?.contentModificationDate, mtime < cutoff {
                    continue
                }

                let path = url.path
                let prev = newCursors[path] ?? FileCursor()
                // No new bytes since last pass → nothing to do.
                if size == prev.size { continue }
                // Truncated / replaced → re-read from the top.
                let start = size < prev.bytesRead ? 0 : prev.bytesRead

                let role: TranscriptRole = path.contains("/subagents/") ? .subagent : .parent
                let (parsed, consumed) = readIncremental(url: url, from: start, role: role)
                events.append(contentsOf: parsed)
                newCursors[path] = FileCursor(bytesRead: start + consumed, size: size)
            }
        }

        return TranscriptReadResult(events: events, cursors: newCursors)
    }

    /// Read from `offset` to EOF, parse complete lines, and report how many
    /// bytes were consumed (up to and including the last newline).
    static func readIncremental(url: URL, from offset: Int, role: TranscriptRole) -> (events: [UsageEvent], consumed: Int) {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return ([], 0) }
        defer { try? handle.close() }
        do { try handle.seek(toOffset: UInt64(max(0, offset))) } catch { return ([], 0) }
        guard let data = try? handle.readToEnd(), !data.isEmpty else { return ([], 0) }

        // Only consume through the last complete line.
        guard let lastNewline = data.lastIndex(of: 0x0A) else { return ([], 0) }
        let complete = data[...lastNewline]
        let consumed = complete.count
        guard let text = String(data: Data(complete), encoding: .utf8) else { return ([], consumed) }

        let events = text
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { ClaudeTranscriptParser.parseLine(String($0), role: role) }
        return (events, consumed)
    }
}
