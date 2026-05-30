import SwiftUI
import HowlAlertUI

/// Liquid Glass popover chrome (HAA-120).
///
/// The floating glass surface the popover content sits on. Content cards inside
/// stay solid navy (brand rule); the shell IS the navigation layer, so it — and
/// only it — wears Liquid Glass. The outer radius is inset-matched to the inner
/// content corner so the glass reads as a clean rim.
struct PopoverShell<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(HowlSpacing.s2)
            .howlGlass(in: RoundedRectangle(
                cornerRadius: HowlRadius.xl + HowlSpacing.s2,
                style: .continuous
            ))
    }
}

// Glass renders live in the Xcode canvas (unlike off-screen ImageRenderer).
#Preview("PopoverShell over wallpaper") {
    ZStack {
        LinearGradient(
            colors: [.cyan, .green, .orange, .red],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        PopoverShell { DetailedPopover() }
            .padding(40)
    }
    .frame(width: 420, height: 1180)
}
