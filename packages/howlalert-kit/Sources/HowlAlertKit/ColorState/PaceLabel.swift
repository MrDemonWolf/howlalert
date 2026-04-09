import SwiftUI

struct PaceLabel: View {
    let paceState: PaceState

    var body: some View {
        Text(labelText)
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var labelText: String {
        switch paceState.status {
        case .onTrack:
            return "On track"
        case .inDebt:
            let pct = Int(abs(paceState.pacePercent))
            if let runsOut = paceState.runsOutAt {
                let remaining = runsOut.timeIntervalSinceNow
                return "\(pct)% in debt — runs out in \(formatDuration(remaining))"
            }
            return "\(pct)% in debt"
        case .inReserve:
            let pct = Int(abs(paceState.pacePercent))
            return "\(pct)% in reserve"
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}
