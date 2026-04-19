import SwiftUI
import HowlAlertKit

@main
struct HowlAlertWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("🐺")
                .font(.largeTitle)
            Text(Greeter().hello())
                .font(.caption)
        }
    }
}
