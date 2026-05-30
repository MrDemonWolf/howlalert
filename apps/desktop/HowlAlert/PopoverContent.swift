import SwiftUI
import HowlAlertUI

/// The menu-bar popover: live usage data bound from `UsageModel`, or the static
/// `.demo` showcase when Demo Mode is on. Wires the Refresh / Quit / Demo
/// actions. (HAA-124)
struct PopoverContent: View {
    @AppStorage("demoMode") private var demoMode = false
    private var model = UsageModel.shared

    var body: some View {
        PopoverShell {
            DetailedPopover(
                data: demoMode ? .demo : model.popoverData,
                demoEnabled: demoMode,
                onRefresh: { model.refresh() },
                onQuit: { NSApp.terminate(nil) },
                onToggleDemo: { demoMode.toggle() }
            )
        }
    }
}
