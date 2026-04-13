// HowlAlertLiveActivity — Dynamic Island + Live Activity
// © 2026 MrDemonWolf, Inc.

import ActivityKit
import SwiftUI
import WidgetKit

struct HowlAlertAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var usagePercent: Int
        var runoutText: String?
        var sourceDeviceName: String?
        var critColor: String // hex
    }
}

// Widget configuration for Live Activities
struct HowlAlertLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HowlAlertAttributes.self) { context in
            // Lock screen / StandBy banner
            HStack(spacing: 12) {
                Text("🐺")
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text("\(context.state.usagePercent)% used")
                        .font(.headline.monospacedDigit())
                    if let runout = context.state.runoutText {
                        Text("Runs out in \(runout)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if let mac = context.state.sourceDeviceName {
                    Text(mac)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(hex: "#091533"))
            .foregroundStyle(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    Text("🐺")
                        .font(.title)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.usagePercent)%")
                        .font(.title2.bold().monospacedDigit())
                        .foregroundStyle(Color(hex: context.state.critColor))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if let runout = context.state.runoutText {
                        Text("Runs out in \(runout)")
                            .font(.caption)
                    }
                }
            } compactLeading: {
                Text("🐺")
            } compactTrailing: {
                Text("\(context.state.usagePercent)%")
                    .foregroundStyle(Color(hex: context.state.critColor))
                    .monospacedDigit()
            } minimal: {
                Text("🐺")
            }
        }
    }
}
