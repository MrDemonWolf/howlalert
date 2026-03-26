import SwiftUI

public enum CritBarSize: Sendable {
	case full      // macOS popover + iOS dashboard
	case compact   // watchOS
	case mini      // notification banner
}

public struct CritBarView: View {
	public let usagePercent: Double
	public let paceState: PaceState?
	public var size: CritBarSize

	public init(usagePercent: Double, paceState: PaceState? = nil, size: CritBarSize = .full) {
		self.usagePercent = usagePercent
		self.paceState = paceState
		self.size = size
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: spacing) {
			bar
			if size == .full, let paceState {
				PaceLabel(paceState: paceState)
					.font(.subheadline)
			}
		}
	}

	// MARK: - Bar

	private var bar: some View {
		GeometryReader { geo in
			ZStack(alignment: .leading) {
				Capsule()
					.fill(ThresholdColor.background.opacity(0.6))

				Capsule()
					.fill(fillColor)
					.frame(width: fillWidth(in: geo.size.width))
					.animation(.easeInOut(duration: 0.35), value: usagePercent)
			}
		}
		.frame(height: barHeight)
	}

	// MARK: - Derived Values

	private var fillColor: Color {
		let state = ThresholdColor.state(for: usagePercent)
		return ThresholdColor.color(for: state)
	}

	private func fillWidth(in totalWidth: CGFloat) -> CGFloat {
		let clamped = min(max(usagePercent, 0), 100)
		return totalWidth * clamped / 100.0
	}

	private var barHeight: CGFloat {
		switch size {
		case .full: return 12
		case .compact: return 6
		case .mini: return 4
		}
	}

	private var spacing: CGFloat {
		switch size {
		case .full: return 6
		case .compact: return 2
		case .mini: return 0
		}
	}
}
