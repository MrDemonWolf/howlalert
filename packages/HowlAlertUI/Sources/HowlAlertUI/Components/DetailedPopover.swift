import SwiftUI

/// Assembled menu-bar dropdown — the reference composition that exercises the
/// whole toolkit. Driven by `PopoverData` (defaults to the `.demo` showcase).
/// Mirrors the DetailedPopover in design-system.html / section-b-macos.html.
public struct DetailedPopover: View {
    @State private var tab = 0

    private let data: PopoverData
    private let onRefresh: (() -> Void)?
    private let onQuit: (() -> Void)?
    private let onToggleDemo: (() -> Void)?
    private let onSettings: (() -> Void)?
    private let demoEnabled: Bool

    public init(
        data: PopoverData = .demo,
        demoEnabled: Bool = false,
        onRefresh: (() -> Void)? = nil,
        onQuit: (() -> Void)? = nil,
        onToggleDemo: (() -> Void)? = nil,
        onSettings: (() -> Void)? = nil
    ) {
        self.data = data
        self.demoEnabled = demoEnabled
        self.onRefresh = onRefresh
        self.onQuit = onQuit
        self.onToggleDemo = onToggleDemo
        self.onSettings = onSettings
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: HowlSpacing.s4) {
            HStack {
                Text("HowlAlert").font(HowlTypography.headline).foregroundStyle(HowlColor.ink100)
                Spacer()
                PaceChip(data.paceText, state: data.paceState)
            }

            CritBar(remaining: data.critRemaining, state: data.critState, label: data.critLabel)
            ResetCountdown(data.resetText, state: data.resetState, lastMinute: data.resetLastMinute)

            PopoverTabBar(
                tabs: ["square.grid.2x2", "clock", "calendar", "calendar.badge.clock"],
                selection: $tab
            )

            usageRow(data.session)
            if let week = data.week { usageRow(week) }

            if !data.models.isEmpty {
                VStack(alignment: .leading, spacing: HowlSpacing.s2) {
                    Text("Recent").font(HowlTypography.caption).foregroundStyle(HowlColor.ink500)
                    ForEach(data.models, id: \.name) { m in
                        ModelRow(name: m.name, points: m.points, value: m.value, state: m.state)
                    }
                }
            }

            VStack(spacing: 0) {
                MenuActionRow(systemImage: "iphone", label: "Open in iPhone",
                              help: "Open HowlAlert on your paired iPhone")
                MenuActionRow(systemImage: "qrcode", label: "Pair device",
                              help: "Pair a new device")
                MenuActionRow(systemImage: "arrow.clockwise", label: "Refresh", shortcut: "⌘R",
                              help: "Recompute usage now") { onRefresh?() }
                    .keyboardShortcut("r", modifiers: .command)
                if onToggleDemo != nil {
                    MenuActionRow(systemImage: "wand.and.stars", label: "Demo data",
                                  shortcut: demoEnabled ? "On" : "Off",
                                  help: "Show example data instead of your live usage") { onToggleDemo?() }
                }
                MenuActionRow(systemImage: "gearshape", label: "Settings", shortcut: "⌘,",
                              help: "HowlAlert settings") { onSettings?() }
                    .keyboardShortcut(",", modifiers: .command)
                MenuActionRow(systemImage: "power", label: "Quit", shortcut: "⌘Q", danger: true,
                              help: "Quit HowlAlert") { onQuit?() }
                    .keyboardShortcut("q", modifiers: .command)
            }

            footer
        }
        .padding(HowlSpacing.s5)
        .frame(width: 340)
        .background(HowlColor.navy900, in: RoundedRectangle(cornerRadius: HowlRadius.xl, style: .continuous))
    }

    /// "Updated …" line. With a live `lastUpdated`, a `TimelineView` re-renders it
    /// every second while the popover is open so the age stays current; otherwise
    /// it falls back to the static `updatedText` (demo).
    @ViewBuilder private var footer: some View {
        if let updatedAt = data.lastUpdated {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(Self.relativeUpdated(since: updatedAt, now: context.date))
                    .font(HowlTypography.caption)
                    .foregroundStyle(HowlColor.ink500)
                    .contentTransition(.numericText())
            }
        } else if let updated = data.updatedText {
            Text(updated).font(HowlTypography.caption).foregroundStyle(HowlColor.ink500)
        }
    }

    /// Brand-voice relative age: "Updated just now" (<5s), then "Updated 12s ago",
    /// "Updated 3m ago", "Updated 1h ago".
    static func relativeUpdated(since: Date, now: Date) -> String {
        let secs = max(0, Int(now.timeIntervalSince(since).rounded()))
        if secs < 5 { return "Updated just now" }
        if secs < 60 { return "Updated \(secs)s ago" }
        let mins = secs / 60
        if mins < 60 { return "Updated \(mins)m ago" }
        return "Updated \(mins / 60)h ago"
    }

    private func usageRow(_ w: PopoverData.Window) -> some View {
        UsageRow(title: w.title, remaining: w.remaining, pace: w.pace, state: w.state,
                 trailingValue: w.trailingValue, metaLeading: w.metaLeading, deficit: w.deficit)
    }
}
