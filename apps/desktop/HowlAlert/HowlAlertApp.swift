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

    /// Placeholder usage state — replaced by live computation in HAA-124.
    @State private var state: HowlState = .warn

    var body: some Scene {
        MenuBarExtra {
            PopoverShell {
                DetailedPopover()
            }
        } label: {
            MenuBarIcon(state: state)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let path = ProcessInfo.processInfo.environment["HOWL_QA_RENDER"] else { return }
        QARenderer.render(to: URL(fileURLWithPath: path))
        NSApp.terminate(nil)
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
        let content = ZStack {
            QAWallpaper()
            DetailedPopover()
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
