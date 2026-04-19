import SwiftUI
import HowlAlertKit

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
        VStack(spacing: 12) {
            Text("🐺 HowlAlert")
                .font(.largeTitle.bold())
            Text("v3 scaffold — \(Greeter().hello())")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
