import SwiftUI
import HowlAlertUI

/// HowlAlert desktop shell.
///
/// HAA-119: menu-bar–only (`LSUIElement`) Xcode shell hosting `DetailedPopover`.
/// HAA-120: real `MenuBarExtra` status item — a state-driven `MenuBarIcon` label,
/// and the popover content floated on a Liquid Glass `PopoverShell` (navigation
/// layer only; content cards stay solid navy).
///
/// The usage `HowlState` is a placeholder here — live data (FSEvents + 5h math)
/// and Demo Mode arrive in HAA-121 / HAA-123 / HAA-124.
///
/// QA harness: `HOWL_QA_RENDER=/path/out.png` renders the popover (over a sample
/// wallpaper so the glass blur is visible) via `ImageRenderer`, then exits.
@main
struct HowlAlertApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra {
            PopoverContent()
        } label: {
            StatusItemLabel()
        }
        .menuBarExtraStyle(.window)

        // Native Preferences window (⌘, from the popover's Settings row).
        Settings {
            SettingsView()
        }
    }
}

/// Menu-bar label, driven by the live `UsageModel` state (HAA-121). Its own
/// view so SwiftUI observation re-renders the icon when usage changes.
private struct StatusItemLabel: View {
    private var model = UsageModel.shared
    var body: some View {
        MenuBarIcon(state: model.state)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let path = ProcessInfo.processInfo.environment["HOWL_QA_RENDER"] {
            QARenderer.render(to: URL(fileURLWithPath: path))
            NSApp.terminate(nil)
            return
        }
        if let dump = ProcessInfo.processInfo.environment["HOWL_USAGE_DUMP"] {
            MainActor.assumeIsolated { UsageModel.shared.dump(to: URL(fileURLWithPath: dump)) }
            NSApp.terminate(nil)
            return
        }
        // Start the live usage pipeline: watch ~/.claude, parse, compute snapshot.
        MainActor.assumeIsolated { UsageModel.shared.start() }
    }
}

/// Headless render of the popover *content* for pixel QA, composited over a
/// sample wallpaper.
///
/// NOTE: this renders `DetailedPopover` WITHOUT the `PopoverShell` glass wrapper.
/// `ImageRenderer` rasterizes off-screen and cannot composite Liquid Glass —
/// `glassEffect` blanks its subtree there. Glass is a live effect: eyeball it in
/// the running menu-bar popover or the `PopoverShell` Xcode `#Preview`. This PNG
/// is for composition / type-scale QA of the content only.
enum QARenderer {
    @MainActor
    static func render(to url: URL) {
        // Render REAL popover data (refresh against ~/.claude first) so the QA
        // PNG reflects the live binding, not the demo showcase.
        UsageModel.shared.refresh()
        let content = ZStack {
            QAWallpaper()
            DetailedPopover(data: UsageModel.shared.popoverData)
                .padding(40)
        }
        .frame(width: 420, height: 1180)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 2
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else {
            FileHandle.standardError.write(Data("HOWL_QA_RENDER: failed to render\n".utf8))
            return
        }
        try? png.write(to: url)
    }
}

/// Sample backdrop used only by the QA renderer to make Liquid Glass legible.
private struct QAWallpaper: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(howlHex: 0x0FACED),
                Color(howlHex: 0x3DDC97),
                Color(howlHex: 0xFFA533),
                Color(howlHex: 0xFF4D4D),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
