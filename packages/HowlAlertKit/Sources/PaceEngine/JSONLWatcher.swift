// JSONLWatcher — FSEvents-based watcher for AI CLI session files
// © 2026 MrDemonWolf, Inc.

#if os(macOS)
import Foundation
import Models
import Providers

public final class JSONLWatcher: @unchecked Sendable {
    private let providers: [any UsageProvider]
    private var stream: FSEventStreamRef?
    private let callback: @Sendable (UsageSnapshot) -> Void
    private let queue = DispatchQueue(label: "com.mrdemonwolf.howlalert.jsonlwatcher")

    public init(
        providers: [any UsageProvider],
        onChange: @escaping @Sendable (UsageSnapshot) -> Void
    ) {
        self.providers = providers
        self.callback = onChange
    }

    deinit {
        stop()
    }

    public func start() {
        let paths = providers.map { $0.sessionPath.path } as CFArray
        var context = FSEventStreamContext()

        let pointer = Unmanaged.passRetained(self).toOpaque()
        context.info = pointer

        guard let stream = FSEventStreamCreate(
            nil,
            { (_, info, numEvents, eventPaths, _, _) in
                guard let info else { return }
                let watcher = Unmanaged<JSONLWatcher>.fromOpaque(info).takeUnretainedValue()
                let paths = unsafeBitCast(eventPaths, to: NSArray.self) as! [String]
                watcher.handleEvents(paths: paths, count: numEvents)
            },
            &context,
            paths,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            1.0, // 1 second latency
            UInt32(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes)
        ) else { return }

        self.stream = stream
        FSEventStreamSetDispatchQueue(stream, queue)
        FSEventStreamStart(stream)
    }

    public func stop() {
        guard let stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        self.stream = nil
    }

    private func handleEvents(paths: [String], count: Int) {
        let jsonlPaths = paths.filter { $0.hasSuffix(".jsonl") }
        guard !jsonlPaths.isEmpty else { return }

        for path in jsonlPaths {
            let url = URL(fileURLWithPath: path)
            for provider in providers {
                guard url.path.hasPrefix(provider.sessionPath.path) else { continue }
                do {
                    let snapshot = try provider.parseSnapshot(from: url)
                    callback(snapshot)
                } catch {
                    // Skip unparseable files silently
                }
                break
            }
        }
    }

    /// Scan all existing JSONL files once on launch.
    public func scanExisting() {
        for provider in providers {
            let path = provider.sessionPath
            guard let enumerator = FileManager.default.enumerator(
                at: path,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            var latestURL: URL?
            var latestDate = Date.distantPast

            while let url = enumerator.nextObject() as? URL {
                guard url.pathExtension == "jsonl" else { continue }
                if let date = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                   date > latestDate {
                    latestDate = date
                    latestURL = url
                }
            }

            if let url = latestURL {
                do {
                    let snapshot = try provider.parseSnapshot(from: url)
                    callback(snapshot)
                } catch {}
            }
        }
    }
}
#endif
