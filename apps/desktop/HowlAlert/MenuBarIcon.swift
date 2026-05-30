import SwiftUI
import HowlAlertUI

/// Menu-bar status-item icon (HAA-120).
///
/// The wolf mark, tinted by usage state. `.ok`/`.fresh` render template-style
/// (adapts to light/dark menu bar); `.warn`/`.crit` take the brand state color,
/// and `.crit` adds a pulsing badge so it reads at a glance. Mirrors the `.howl`
/// icon in section-b-macos.html.
struct MenuBarIcon: View {
    let state: HowlState
    @State private var pulse = false

    private var isAttention: Bool { state == .warn || state == .crit }

    var body: some View {
        WolfMark(.mono, size: 18)
            .foregroundStyle(isAttention ? state.color : Color.primary)
            .overlay(alignment: .topTrailing) {
                if state == .crit {
                    Circle()
                        .fill(HowlColor.stateCrit)
                        .frame(width: 6, height: 6)
                        .offset(x: 1, y: -1)
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
