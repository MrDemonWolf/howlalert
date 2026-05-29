import SwiftUI

/// Assembled menu-bar dropdown — the reference composition that exercises the whole toolkit.
/// Mirrors the DetailedPopover in design-system.html / section-b-macos.html.
public struct DetailedPopover: View {
    @State private var tab = 0

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: HowlSpacing.s4) {
            HStack {
                Text("HowlAlert").font(HowlTypography.headline).foregroundStyle(HowlColor.ink100)
                Spacer()
                PaceChip("Runs out in 47m", state: .warn)
            }

            CritBar(remaining: 0.16, state: .warn, label: "5-hour window")
            ResetCountdown("Resets in 47m", state: .warn, lastMinute: false)

            PopoverTabBar(
                tabs: ["square.grid.2x2", "clock", "calendar", "calendar.badge.clock"],
                selection: $tab
            )

            UsageRow(title: "Session", remaining: 0.16, pace: 0.4, state: .warn,
                     trailingValue: "16%", metaLeading: "3.2M tokens", deficit: "runs out in 47m")
            UsageRow(title: "Week", remaining: 0.62, pace: 0.55, state: .ok,
                     trailingValue: "62%", metaLeading: "Resets Sunday")

            VStack(alignment: .leading, spacing: HowlSpacing.s2) {
                Text("Recent").font(HowlTypography.caption).foregroundStyle(HowlColor.ink500)
                ModelRow(name: "Opus 4.7", points: [2, 3, 5, 4, 7, 6, 9], value: "1.8M", state: .warn)
                ModelRow(name: "Sonnet 4.6", points: [1, 2, 2, 3, 2, 4, 3], value: "0.9M", state: .ok)
            }

            VStack(spacing: 0) {
                MenuActionRow(systemImage: "iphone", label: "Open in iPhone")
                MenuActionRow(systemImage: "qrcode", label: "Pair device")
                MenuActionRow(systemImage: "arrow.clockwise", label: "Refresh", shortcut: "⌘R")
                MenuActionRow(systemImage: "gearshape", label: "Settings", shortcut: "⌘,")
                MenuActionRow(systemImage: "power", label: "Quit", shortcut: "⌘Q", danger: true)
            }
        }
        .padding(HowlSpacing.s5)
        .frame(width: 340)
        .background(HowlColor.navy900, in: RoundedRectangle(cornerRadius: HowlRadius.xl, style: .continuous))
    }
}
