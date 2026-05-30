import SwiftUI
import HowlAlertUI

/// Menu-bar status-item icon (HAA-120 / HAA-124).
///
/// Placeholder SF Symbol for now — a system symbol auto-sizes and template-
/// renders correctly in the menu bar (the custom `WolfShape` didn't, so it read
/// as nearly invisible). HIG-correct for a status item: monochrome by default so
/// it adapts to the light/dark menu bar, taking the brand state color only when
/// something needs attention. State changes `.bounce` once; `.crit` pulses — both
/// via native `.symbolEffect` (macOS 26) rather than hand-rolled animation. Swap
/// back to a properly-rendered wolf template in a later polish pass.
struct MenuBarIcon: View {
    let state: HowlState

    private var isAttention: Bool { state == .warn || state == .crit }

    var body: some View {
        Image(systemName: "gauge.with.dots.needle.bottom.50percent")
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(isAttention ? state.color : Color.primary)
            .overlay(alignment: .topTrailing) {
                if state == .crit {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 5))
                        .foregroundStyle(HowlColor.stateCrit)
                        .offset(x: 2, y: -2)
                        .symbolEffect(.pulse, options: .repeating)
                }
            }
            // Nudge the glyph on every state transition (the badge carries the
            // continuous pulse while critical).
            .symbolEffect(.bounce, value: state)
            .accessibilityLabel("HowlAlert — \(accessibilityState)")
    }

    private var accessibilityState: String {
        switch state {
        case .fresh: "idle"
        case .ok: "on track"
        case .warn: "running low"
        case .crit: "almost out"
        }
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
