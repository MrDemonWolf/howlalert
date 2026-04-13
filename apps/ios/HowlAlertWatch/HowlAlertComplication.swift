// HowlAlertComplication — Circular complication for watch faces
// © 2026 MrDemonWolf, Inc.

import WidgetKit
import SwiftUI

struct HowlAlertComplicationEntry: TimelineEntry {
    let date: Date
    let usagePercent: Double
    let critColorHex: String
}

struct HowlAlertComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> HowlAlertComplicationEntry {
        HowlAlertComplicationEntry(date: .now, usagePercent: 42, critColorHex: "#0FACED")
    }

    func getSnapshot(in context: Context, completion: @escaping (HowlAlertComplicationEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HowlAlertComplicationEntry>) -> Void) {
        // Updated via WatchConnectivity push, not polling
        let entry = HowlAlertComplicationEntry(date: .now, usagePercent: 42, critColorHex: "#0FACED")
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(15 * 60)))
        completion(timeline)
    }
}

struct HowlAlertComplicationView: View {
    let entry: HowlAlertComplicationEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("🐺")
                    .font(.caption)
                Text("\(Int(entry.usagePercent))")
                    .font(.system(.body, design: .rounded).bold().monospacedDigit())
                    .foregroundStyle(Color(hex: entry.critColorHex))
            }
        }
        .widgetAccentable()
    }
}

// Note: This widget needs a separate WidgetExtension target in Xcode.
// For now, defined as a struct to be wired up in Phase 10 polish.
struct HowlAlertComplicationWidget: Widget {
    let kind = "HowlAlertComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HowlAlertComplicationProvider()) { entry in
            HowlAlertComplicationView(entry: entry)
        }
        .configurationDisplayName("HowlAlert")
        .description("Claude Code usage at a glance.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}
