// HowlAlert macOS — Menu Bar App Entry Point
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import Models

@main
struct HowlAlertApp: App {
    var body: some Scene {
        MenuBarExtra("HowlAlert", systemImage: "pawprint.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)

        Settings {
            PreferencesPlaceholderView()
        }
    }
}

struct MenuBarView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🐺 HowlAlert")
                    .font(.headline)
                Spacer()
            }

            Text("Waiting for Claude Code...")
                .foregroundStyle(.secondary)
                .font(.caption)

            Divider()

            Button("Preferences...") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }

            Button("Quit HowlAlert") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
        .frame(width: 280)
    }
}

struct PreferencesPlaceholderView: View {
    var body: some View {
        Text("Preferences will be configured in Phase 7")
            .padding(40)
    }
}
