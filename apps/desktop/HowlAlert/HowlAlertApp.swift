import SwiftUI
import HowlAlertUI

/// HowlAlert desktop shell (HAA-119).
///
/// Phase-0 scaffold: a menu-bar–only (`LSUIElement`) app that hosts the
/// `DetailedPopover` from `HowlAlertUI` so the design system (HAA-118) can be
/// visually QA'd against `apps/docs/design-bundle/section-b-macos.html`.
///
/// `MenuBarExtra` with `.window` style IS the shipping surface — clicking the
/// menu-bar icon shows the exact popover users will see. No Dock icon, no
/// main window. FSEvents / Stop hook / usage math land in later tickets.
///
/// QA harness: set `HOWL_QA_RENDER=/path/to/out.png` before launch and the app
/// renders `DetailedPopover` straight to a PNG via `ImageRenderer` and exits —
/// headless pixel QA with no menu-bar interaction needed.
@main
struct HowlAlertApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra("HowlAlert", systemImage: "wave.3.right") {
            DetailedPopover()
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let path = ProcessInfo.processInfo.environment["HOWL_QA_RENDER"] else { return }
        renderQAImage(to: URL(fileURLWithPath: path))
        NSApp.terminate(nil)
    }

    @MainActor
    private func renderQAImage(to url: URL) {
        let renderer = ImageRenderer(content: DetailedPopover().padding(24).background(HowlColor.navy900))
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
