import SwiftUI

public enum CritBarSize {
    case full      // menu bar popover, iOS dashboard
    case compact   // watch complication
    case mini      // notification banner
}

public struct CritBarView: View {
    let usagePercent: Double  // 0.0 to 1.0
    let paceState: PaceState?
    let size: CritBarSize
    let justReset: Bool

    public init(
        usagePercent: Double,
        paceState: PaceState? = nil,
        size: CritBarSize = .full,
        justReset: Bool = false
    ) {
        self.usagePercent = usagePercent
        self.paceState = paceState
        self.size = size
        self.justReset = justReset
    }

    private var barColor: Color {
        ThresholdColor.color(for: usagePercent, justReset: justReset).color
    }

    private var barHeight: CGFloat {
        switch size {
        case .full:    return 12
        case .compact: return 8
        case .mini:    return 6
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(barColor)
                        .frame(width: geo.size.width * min(usagePercent, 1.0))
                        .animation(.easeInOut(duration: 0.3), value: usagePercent)
                }
            }
            .frame(height: barHeight)

            if size == .full, let pace = paceState {
                PaceLabel(paceState: pace)
            }
        }
    }
}
