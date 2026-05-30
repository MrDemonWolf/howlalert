import Foundation
import Observation
import HowlAlertCore
import HowlAlertUI

/// Live usage state for the app — reads `~/.claude` transcripts via
/// `HowlAlertCore`, recomputes a `UsageSnapshot` on file changes (FSEvents) and
/// on a periodic timer, and publishes it for the UI.
///
/// HAA-121 wires this pipeline and drives the menu-bar icon's state. Binding the
/// snapshot into `DetailedPopover` + Demo Mode is HAA-124.
@MainActor
@Observable
final class UsageModel {
    static let shared = UsageModel()

    private(set) var snapshot: UsageSnapshot?

    /// Menu-bar state — `.fresh` when there's no active window yet. Maps the
    /// Core `UsageState` onto the UI `HowlState` (separate enums, same cases).
    var state: HowlState {
        switch snapshot?.state {
        case .fresh, nil: .fresh
        case .ok: .ok
        case .warn: .warn
        case .crit: .crit
        }
    }

    private let roots: [URL]
    private let config: LimitsConfig
    private let retention: TimeInterval
    private var cursors: [String: FileCursor] = [:]
    private var events: [UsageEvent] = []
    private var watcher: TranscriptWatcher?
    private var timer: Timer?

    init(config: LimitsConfig = .howlBundledDefault, retentionDays: Double = 14) {
        self.roots = ClaudeConfig.discoverTranscriptRoots()
        self.config = config
        self.retention = retentionDays * 86_400
    }

    /// Begin watching + a one-shot initial read, plus a 60s safety-net timer.
    func start() {
        refresh()
        let watcher = TranscriptWatcher(roots: roots) { [weak self] in
            Task { @MainActor in self?.refresh() }
        }
        watcher.start()
        self.watcher = watcher

        let timer = Timer(timeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    /// One-shot: refresh against real transcripts and write the snapshot to a
    /// file. Diagnostic hook (`HOWL_USAGE_DUMP`) since a menu-bar app's stdout
    /// isn't easily captured.
    func dump(to url: URL, now: Date = Date()) {
        refresh(now: now)
        let text: String
        if let s = snapshot {
            let pct = Int((s.fractionUsed * 100).rounded())
            let mins = Int(s.timeUntilReset / 60)
            text = """
            roots: \(roots.map(\.path).joined(separator: ", "))
            events (deduped, ≤retention): \(events.count)
            window start: \(s.windowStart)
            resets at:    \(s.resetsAt) (in \(mins)m)
            tokens used:  \(s.tokensUsed)
            limit (P90):  \(s.limit)
            used:         \(pct)%   state=\(s.state)
            run-out proj: \(s.projectedRunOut.map(String.init(describing:)) ?? "—")  lastsToReset=\(s.willLastToReset)
            """
        } else {
            text = "roots: \(roots.map(\.path).joined(separator: ", "))\nevents: \(events.count)\nno active 5h window (fresh)"
        }
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Incrementally read new transcript bytes and recompute the snapshot.
    func refresh(now: Date = Date()) {
        let cutoff = now.addingTimeInterval(-retention)
        let result = TranscriptReader.read(roots: roots, cursors: cursors, modifiedAfter: cutoff)
        cursors = result.cursors

        if !result.events.isEmpty {
            events.append(contentsOf: result.events)
            // Dedupe across files and prune anything past the retention window.
            events = ClaudeTranscriptParser.deduped(events).filter { $0.timestamp >= cutoff }
        }

        snapshot = UsageEngine.snapshot(events: events, config: config, now: now)
        logSnapshot()
    }

    private func logSnapshot() {
        let line: String
        if let s = snapshot {
            let pct = Int((s.fractionUsed * 100).rounded())
            line = "[HowlAlert] \(s.tokensUsed)/\(s.limit) tokens (\(pct)%) state=\(s.state) resets=\(s.resetsAt)\n"
        } else {
            line = "[HowlAlert] no active 5h window (fresh)\n"
        }
        FileHandle.standardError.write(Data(line.utf8))
    }
}

extension LimitsConfig {
    /// Bundled fallback only — used until enough history exists for the P90
    /// estimate to take over (and, later, a remote `limits.json`). Kept low so
    /// it acts as a floor, never inflating a real P90. NOT a real plan limit.
    static let howlBundledDefault = LimitsConfig(minSamples: 5, fallbackLimit: 100_000)
}
