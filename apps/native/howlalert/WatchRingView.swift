//
//  WatchRingView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

#if os(watchOS)
import SwiftUI

struct WatchRingView: View {
	var tokensUsed: Int
	var tokenLimit: Int
	var isDemo: Bool = false

	private var progress: Double {
		min(Double(tokensUsed) / max(Double(tokenLimit), 1), 1.0)
	}

	private var ringColor: Color {
		if progress >= 0.9 { return .red }
		if progress >= 0.7 { return .orange }
		return .green
	}

	var body: some View {
		TimelineView(.periodic(from: .now, by: 1)) { _ in
			ZStack {
				// Background track
				Circle()
					.stroke(Color.gray.opacity(0.25), style: StrokeStyle(lineWidth: 8, lineCap: .round))

				// Progress arc
				Circle()
					.trim(from: 0, to: progress)
					.stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
					.rotationEffect(.degrees(-90))
					.animation(.easeInOut(duration: 0.4), value: progress)

				// Center content
				VStack(spacing: 2) {
					Text(Date(), style: .time)
						.font(.system(.body, design: .rounded, weight: .semibold))
						.minimumScaleFactor(0.6)
						.lineLimit(1)

					Text("\(formatK(tokensUsed)) / \(formatK(tokenLimit))")
						.font(.caption2)
						.foregroundStyle(.secondary)
						.minimumScaleFactor(0.5)
						.lineLimit(1)
				}
				.padding(18)
			}
		}
	}

	private func formatK(_ n: Int) -> String {
		if n >= 1_000_000 {
			let val = Double(n) / 1_000_000
			return String(format: val.truncatingRemainder(dividingBy: 1) == 0 ? "%.0fM" : "%.1fM", val)
		} else if n >= 1_000 {
			let val = Double(n) / 1_000
			return String(format: val.truncatingRemainder(dividingBy: 1) == 0 ? "%.0fK" : "%.1fK", val)
		}
		return "\(n)"
	}
}

#Preview {
	WatchRingView(tokensUsed: 145_230, tokenLimit: 200_000)
		.frame(width: 180, height: 180)
}
#endif
