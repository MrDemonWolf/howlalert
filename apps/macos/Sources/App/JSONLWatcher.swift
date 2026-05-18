// JSONLWatcher.swift
//
// FSEvents-backed tail of `~/.claude/projects/**/*.jsonl`. Coalesces file
// events into a 0.5s window, reads newly-appended bytes per file, and emits
// parsed ClaudeEvent values to subscribers.

import Foundation
import HowlAlertKit
@preconcurrency import CoreServices

@MainActor
final class JSONLWatcher {
    typealias EventHandler = @MainActor ([ClaudeEvent]) -> Void

    private let root: URL
    private var stream: FSEventStreamRef?
    private var offsets: [String: UInt64] = [:]
    private var handler: EventHandler?

    init(root: URL = JSONLWatcher.defaultRoot) {
        self.root = root
    }

    static var defaultRoot: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appending(path: ".claude/projects", directoryHint: .isDirectory)
    }

    func start(handler: @escaping EventHandler) {
        stop()
        self.handler = handler
        // Seed offsets so we only emit events for *new* lines appended after
        // the watcher starts; otherwise relaunching the app would replay
        // historical usage.
        seedOffsets()

        let callback: FSEventStreamCallback = { _, info, count, paths, _, _ in
            guard let info else { return }
            let watcher = Unmanaged<JSONLWatcher>.fromOpaque(info).takeUnretainedValue()
            guard let cPaths = paths.bindMemory(to: UnsafePointer<CChar>.self, capacity: count) as UnsafeMutablePointer<UnsafePointer<CChar>>? else { return }
            var changed: [String] = []
            for i in 0..<count {
                changed.append(String(cString: cPaths[i]))
            }
            Task { @MainActor in
                watcher.processChanged(paths: changed)
            }
        }

        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let paths = [root.path(percentEncoded: false)] as CFArray
        guard let stream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &context,
            paths,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.5,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagNoDefer)
        ) else { return }

        FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)
        FSEventStreamStart(stream)
        self.stream = stream
    }

    func stop() {
        if let stream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            self.stream = nil
        }
        handler = nil
    }

    private func seedOffsets() {
        guard let it = FileManager.default.enumerator(at: root, includingPropertiesForKeys: [.fileSizeKey]) else { return }
        for case let url as URL in it where url.pathExtension == "jsonl" {
            if let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                offsets[url.path] = UInt64(size)
            }
        }
    }

    private func processChanged(paths: [String]) {
        var events: [ClaudeEvent] = []
        for path in paths where path.hasSuffix(".jsonl") {
            events.append(contentsOf: drain(path: path))
        }
        if !events.isEmpty {
            handler?(events)
        }
    }

    private func drain(path: String) -> [ClaudeEvent] {
        guard let handle = try? FileHandle(forReadingFrom: URL(fileURLWithPath: path)) else { return [] }
        defer { try? handle.close() }

        let previous = offsets[path] ?? 0
        do {
            try handle.seek(toOffset: previous)
        } catch {
            return []
        }
        guard let data = try? handle.readToEnd(), !data.isEmpty else { return [] }
        let size = (try? handle.offset()) ?? previous + UInt64(data.count)
        offsets[path] = size
        guard let text = String(data: data, encoding: .utf8) else { return [] }
        return JSONLEventParser.parse(chunk: text)
    }
}
