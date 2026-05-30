import SwiftUI
import HowlAlertUI

/// Menu-bar status-item icon (HAA-120 / HAA-124).
///
/// Placeholder SF Symbol for now — a system symbol auto-sizes and template-
/// renders correctly in the menu bar (the custom `WolfShape` didn't, so it read
/// as nearly invisible). `.ok`/`.fresh` render monochrome (adapts to light/dark
/// menu bar); `.warn`/`.crit` take the brand state color; `.crit` adds a pulsing
/// badge. Swap back to a properly-rendered wolf template in a later polish pass.
struct MenuBarIcon: View {
    let state: HowlState
    @State private var pulse = false

    private var isAttention: Bool { state == .warn || state == .crit }

    var body: some View {
        Image(systemName: "gauge.with.dots.needle.bottom.50percent")
            .foregroundStyle(isAttention ? state.color : Color.primary)
            .overlay(alignment: .topTrailing) {
                if state == .crit {
                    Circle()
                        .fill(HowlColor.stateCrit)
                        .frame(width: 5, height: 5)
                        .offset(x: 2, y: -2)
                        .scaleEffect(pulse ? 1.0 : 0.55)
                        .opacity(pulse ? 1.0 : 0.4)
                        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
                        .onAppear { pulse = true }
                }
            }
            .accessibilityLabel("HowlAlert — \(state)")
    }
}

#Preview("MenuBarIcon states") {
    HStack(spacing: 20) {
        MenuBarIcon(state: .fresh)
        MenuBarIcon(state: .ok)
        MenuBarIcon(state: .warn)
        MenuBarIcon(state: .crit)
    }
    .padding(30)
    .background(.black)
}
