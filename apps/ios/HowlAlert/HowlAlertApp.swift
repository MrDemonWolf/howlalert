// HowlAlert iOS — App Entry Point
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import Models

@main
struct HowlAlertApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🐺")
                    .font(.system(size: 64))
                Text("HowlAlert")
                    .font(.largeTitle.bold())
                Text("Waiting for Mac...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#091533"))
            .preferredColorScheme(.dark)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
