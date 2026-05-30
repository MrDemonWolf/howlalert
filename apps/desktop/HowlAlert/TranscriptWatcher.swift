import Foundation
import CoreServices

/// Watches the Claude transcript roots with FSEvents and fires `onChange` when
/// anything under them changes. The stream's own latency debounces bursts of
/// writes, so callers get a coalesced nudge rather than one call per byte.
///
/// macOS-only (FSEvents). The actual reading/parsing lives in `HowlAlertCore`'s
/// `TranscriptReader`; this just says "something moved, go look."
final class TranscriptWatcher {
    private let paths: [String]
    private let onChange: () -> Void
    private let queue = DispatchQueue(label: "com.howlalert.fswatch")
    private var stream: FSEventStreamRef?

    init(roots: [URL], onChange: @escaping () -> Void) {
        self.paths = roots.map(\.path)
        self.onChange = onChange
    }

    func start() {
        guard stream == nil, !paths.isEmpty else { return }

        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let callback: FSEventStreamCallback = { _, info, _, _, _, _ in
            guard let info else { return }
            let watcher = Unmanaged<TranscriptWatcher>.fromOpaque(info).takeUnretainedValue()
            watcher.onChange()
        }

        let flags = UInt32(
            kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagNoDefer | kFSEventStreamCreateFlagUseCFTypes
        )

        guard let stream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &context,
            paths as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            1.0, // latency (s) — coalesces write bursts
            flags
        ) else { return }

        FSEventStreamSetDispatchQueue(stream, queue)
        FSEventStreamStart(stream)
        self.stream = stream
    }

    func stop() {
        guard let stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        self.stream = nil
    }

    deinit { stop() }
}
