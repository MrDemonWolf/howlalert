// HowlAlert watchOS — App Entry Point
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import Models

@main
struct HowlAlertWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
    }
}

struct WatchContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("🐺")
                .font(.title)
            Text("HowlAlert")
                .font(.headline)
            Text("Waiting...")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
}
