// CritBarView — Color-coded usage progress bar
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import ColorState

struct CritBarView: View {
    let percent: Double
    let critState: CritState

    private var barColor: Color {
        let hex: String
        switch critState {
        case .ok: hex = "#0FACED"
        case .approaching: hex = "#F5A623"
        case .limitHit: hex = "#FF3B30"
        case .reset: hex = "#34C759"
        }
        return Color(hex: hex)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white.opacity(0.1))

                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(width: geo.size.width * min(percent / 100, 1.0))
                    .animation(.easeInOut(duration: 0.5), value: percent)
            }
        }
        .frame(height: 8)
        .accessibilityLabel("Session usage, \(Int(percent)) percent, \(critState.rawValue)")
    }
}
