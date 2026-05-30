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
    private let demoEnabled: Bool

    public init(
        data: PopoverData = .demo,
        demoEnabled: Bool = false,
        onRefresh: (() -> Void)? = nil,
        onQuit: (() -> Void)? = nil,
        onToggleDemo: (() -> Void)? = nil
    ) {
        self.data = data
        self.demoEnabled = demoEnabled
        self.onRefresh = onRefresh
        self.onQuit = onQuit
        self.onToggleDemo = onToggleDemo
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
                MenuActionRow(systemImage: "iphone", label: "Open in iPhone")
                MenuActionRow(systemImage: "qrcode", label: "Pair device")
                MenuActionRow(systemImage: "arrow.clockwise", label: "Refresh", shortcut: "⌘R")
                    .onTapGesture { onRefresh?() }
                if onToggleDemo != nil {
                    MenuActionRow(systemImage: "wand.and.stars", label: "Demo data",
                                  shortcut: demoEnabled ? "on" : "off")
                        .onTapGesture { onToggleDemo?() }
                }
                MenuActionRow(systemImage: "gearshape", label: "Settings", shortcut: "⌘,")
                MenuActionRow(systemImage: "power", label: "Quit", shortcut: "⌘Q", danger: true)
                    .onTapGesture { onQuit?() }
            }

            if let updated = data.updatedText {
                Text(updated).font(HowlTypography.caption).foregroundStyle(HowlColor.ink500)
            }
        }
        .padding(HowlSpacing.s5)
        .frame(width: 340)
        .background(HowlColor.navy900, in: RoundedRectangle(cornerRadius: HowlRadius.xl, style: .continuous))
    }

    private func usageRow(_ w: PopoverData.Window) -> some View {
        UsageRow(title: w.title, remaining: w.remaining, pace: w.pace, state: w.state,
                 trailingValue: w.trailingValue, metaLeading: w.metaLeading, deficit: w.deficit)
    }
}
