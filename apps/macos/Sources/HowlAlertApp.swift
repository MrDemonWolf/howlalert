import SwiftUI
import HowlAlertKit

@main
struct HowlAlertApp: App {
    var body: some Scene {
        MenuBarExtra("HowlAlert", systemImage: "bolt.fill") {
            VStack(alignment: .leading, spacing: 8) {
                Text("HowlAlert — v3 scaffold")
                    .font(.headline)
                Text(Greeter().hello())
                    .font(.caption)
                Divider()
                Button("Quit") { NSApp.terminate(nil) }
            }
            .padding(12)
        }
    }
}
