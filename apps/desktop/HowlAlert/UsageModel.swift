import Foundation
import Observation
import UserNotifications
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

    /// When `refresh()` last recomputed the snapshot — drives the popover's live
    /// "Updated Ns ago" footer.
    private(set) var lastRefresh: Date?

    /// Refresh cadence (seconds) for the safety-net timer, settings-controlled
    /// (`refreshInterval`). FSEvents + the Stop hook drive instant updates; this
    /// is just the floor. Default 60s; 0/unset → 60.
    static let defaultRefreshInterval: TimeInterval = 60
    private var refreshInterval: TimeInterval {
        let v = UserDefaults.standard.double(forKey: "refreshInterval")
        return v > 0 ? v : Self.defaultRefreshInterval
    }

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

    /// True only while the real pipeline is running (`start()`), so the QA-render
    /// and `dump` paths — which also call `refresh()` — never post notifications.
    private var isLive = false
    /// Last state we notified about, to fire only on a rise in severity (and to
    /// re-arm once usage drops, e.g. after a window reset).
    private var lastNotifiedState: HowlState?

    init(config: LimitsConfig = .howlBundledDefault, retentionDays: Double = 14) {
        self.roots = ClaudeConfig.discoverTranscriptRoots()
        self.config = config
        self.retention = retentionDays * 86_400
    }

    /// Begin watching + a one-shot initial read, plus a 60s safety-net timer.
    func start() {
        isLive = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        refresh()
        let watcher = TranscriptWatcher(roots: roots) { [weak self] in
            Task { @MainActor in self?.refresh() }
        }
        watcher.start()
        self.watcher = watcher

        armTimer()

        // Instant refresh when a Claude Code turn ends (Stop hook → HAA-122).
        HowlSignal.observeStop { [weak self] in
            Task { @MainActor in self?.refresh() }
        }
    }

    /// (Re)build the safety-net timer at the current `refreshInterval`. Call after
    /// the user changes the cadence in Settings.
    func armTimer() {
        timer?.invalidate()
        let timer = Timer(timeInterval: refreshInterval, repeats: true) { [weak self] _ in
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
        lastRefresh = now
        notifyIfNeeded()
        logSnapshot()
    }

    // MARK: - Local notifications

    /// Post a local notification when usage crosses *up* into warn/crit (gated by
    /// the per-threshold Settings toggles). Fires once per rise — never every
    /// refresh — and re-arms when usage drops (e.g. after a window reset). The
    /// first live snapshot only seeds the baseline so launch is silent.
    private func notifyIfNeeded() {
        guard isLive else { return }
        let current = state

        guard let last = lastNotifiedState else {
            lastNotifiedState = current   // seed: no notification on first refresh
            return
        }

        // Usage eased off — re-arm so the next rise notifies again.
        if Self.severity(current) < Self.severity(last) {
            lastNotifiedState = current
            return
        }
        // No rise → nothing to announce.
        guard Self.severity(current) > Self.severity(last) else { return }

        let defaults = UserDefaults.standard
        let wantsWarn = defaults.object(forKey: "notifyLow") as? Bool ?? true
        let wantsCrit = defaults.object(forKey: "notifyAlmostOut") as? Bool ?? true

        let content: (title: String, body: String)?
        switch current {
        case .crit where wantsCrit: content = ("Almost out", notificationBody())
        case .warn where wantsWarn: content = ("Running low", notificationBody())
        default: content = nil
        }

        // Always advance the baseline so we don't re-evaluate this rise next time,
        // even if the matching toggle is off.
        lastNotifiedState = current
        guard let content else { return }

        let note = UNMutableNotificationContent()
        note.title = content.title
        note.body = content.body
        note.sound = .default
        let request = UNNotificationRequest(identifier: "howl.window.\(current)", content: note, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    /// Body line in the brand voice, e.g. "16% of your 5-hour window left · resets in 47m".
    private func notificationBody() -> String {
        guard let s = snapshot else { return "Your 5-hour window is running down." }
        let pct = Int((s.fractionRemaining * 100).rounded())
        return "\(pct)% of your 5-hour window left · resets in \(naturalDuration(s.timeUntilReset))"
    }

    /// Severity rank for transition comparisons.
    private static func severity(_ state: HowlState) -> Int {
        switch state {
        case .fresh: 0
        case .ok: 1
        case .warn: 2
        case .crit: 3
        }
    }

    /// Live snapshot mapped into popover view data. The weekly window isn't
    /// wired yet (needs more history than retention) so `week` stays nil here.
    var popoverData: PopoverData {
        guard let s = snapshot else {
            return PopoverData(
                paceText: "On track", paceState: .ok,
                critRemaining: 1, critState: .fresh, critLabel: "5-hour window",
                resetText: "No active session", resetState: .fresh, resetLastMinute: false,
                session: .init(title: "Session", remaining: 1, pace: 0, state: .fresh,
                               trailingValue: "100%", metaLeading: "Idle"),
                models: modelRows(), lastUpdated: lastRefresh
            )
        }
        let remaining = s.fractionRemaining
        let elapsed = min(1, max(0, s.now.timeIntervalSince(s.windowStart) / FiveHourWindow.duration))
        let pace = paceDescriptor(s)
        return PopoverData(
            paceText: pace.text, paceState: pace.state,
            critRemaining: remaining, critState: state, critLabel: "5-hour window",
            resetText: "Resets in \(naturalDuration(s.timeUntilReset))",
            resetState: state, resetLastMinute: s.timeUntilReset < 60,
            session: .init(title: "Session", remaining: remaining, pace: elapsed, state: state,
                           trailingValue: "\(Int((remaining * 100).rounded()))%",
                           metaLeading: "\(formatTokens(s.tokensUsed)) tokens",
                           deficit: s.willLastToReset ? nil : pace.text.lowercased()),
            models: modelRows(), lastUpdated: lastRefresh
        )
    }

    private func paceDescriptor(_ s: UsageSnapshot) -> (text: String, state: HowlState) {
        guard !s.willLastToReset, let runOut = s.projectedRunOut else { return ("On track", .ok) }
        return ("Runs out in \(naturalDuration(max(0, runOut.timeIntervalSince(s.now))))", state)
    }

    private func modelRows() -> [PopoverData.Model] {
        UsageEngine.recentModels(events: events, now: lastRefresh ?? Date()).map {
            PopoverData.Model(name: prettyModel($0.model), points: $0.sparkline,
                              value: formatTokens($0.totalTokens), state: .ok)
        }
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

        // Diagnostic: when HOWL_SIGNAL_PROBE is set, append a line per refresh so
        // the FSEvents / Stop-hook pipeline can be observed from a file (a GUI
        // app's stderr isn't reliably capturable).
        if let probe = ProcessInfo.processInfo.environment["HOWL_SIGNAL_PROBE"] {
            let url = URL(fileURLWithPath: probe)
            let entry = Data("refresh \(Date())\n".utf8)
            if let h = try? FileHandle(forWritingTo: url) {
                defer { try? h.close() }
                _ = try? h.seekToEnd()
                h.write(entry)
            } else {
                try? entry.write(to: url)
            }
        }
    }
}

// MARK: - Formatting

/// "3.2M", "950K", "420" — compact token counts.
func formatTokens(_ n: Int) -> String {
    let value = Double(n)
    if value >= 1_000_000 { return String(format: "%.1fM", value / 1_000_000) }
    if value >= 1_000 { return String(format: "%.0fK", value / 1_000) }
    return "\(n)"
}

/// "47m", "2h 5m" — natural, watching-not-monitoring voice.
func naturalDuration(_ seconds: TimeInterval) -> String {
    let total = max(0, Int(seconds.rounded()))
    let minutes = total / 60
    if minutes < 60 { return "\(minutes)m" }
    return "\(minutes / 60)h \(minutes % 60)m"
}

/// "claude-opus-4-7" → "Opus 4.7"; falls back to the raw id.
func prettyModel(_ id: String) -> String {
    var parts = id.split(separator: "-").map(String.init)
    if parts.first == "claude" { parts.removeFirst() }
    guard let family = parts.first else { return id }
    let version = parts.dropFirst().joined(separator: ".")
    let name = family.prefix(1).uppercased() + family.dropFirst()
    return version.isEmpty ? name : "\(name) \(version)"
}

extension LimitsConfig {
    /// Bundled fallback only — used until enough history exists for the P90
    /// estimate to take over (and, later, a remote `limits.json`). Kept low so
    /// it acts as a floor, never inflating a real P90. NOT a real plan limit.
    static let howlBundledDefault = LimitsConfig(minSamples: 5, fallbackLimit: 100_000)
}
