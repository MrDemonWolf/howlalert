//
//  UsageProgressBar.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/18/26.
//

import SwiftUI
import HowlAlertKit

/// Progress bar matching CodexBar's MetricRow pattern:
/// Title (.body .medium) -> Capsule bar (6pt) -> HStack with percent left + detail right (.footnote)
/// Optionally shows pace text and ETA below the bar.
struct UsageProgressBar: View {
	let title: String
	let percent: Double
	let percentLabel: String
	let detailText: String?
	let tint: Color
	let resetText: String?
	let paceText: String?
	let etaText: String?
	let paceStage: UsagePace.Stage?

	init(
		title: String,
		percent: Double,
		percentLabel: String,
		detailText: String? = nil,
		tint: Color = .accentColor,
		resetText: String? = nil,
		paceText: String? = nil,
		etaText: String? = nil,
		paceStage: UsagePace.Stage? = nil
	) {
		self.title = title
		self.percent = percent
		self.percentLabel = percentLabel
		self.detailText = detailText
		self.tint = tint
		self.resetText = resetText
		self.paceText = paceText
		self.etaText = etaText
		self.paceStage = paceStage
	}

	private var clamped: Double {
		min(1.0, max(0, percent))
	}

	private var barColor: Color {
		if let stage = paceStage {
			switch stage {
			case .comfortable: return .green
			case .onTrack: return .green
			case .moderate: return .yellow
			case .concerning: return .orange
			case .critical: return .red
			}
		}
		if percent >= 1.0 { return .red }
		if percent >= 0.8 { return .orange }
		return tint
	}

	private var trackColor: Color {
		#if os(macOS)
		Color(nsColor: .separatorColor).opacity(0.3)
		#else
		Color.gray.opacity(0.25)
		#endif
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title)
				.font(.body)
				.fontWeight(.medium)

			GeometryReader { proxy in
				ZStack(alignment: .leading) {
					Capsule()
						.fill(trackColor)

					Capsule()
						.fill(barColor)
						.frame(width: max(0, proxy.size.width * clamped))
				}
			}
			.frame(height: 6)

			HStack(alignment: .firstTextBaseline) {
				Text(percentLabel)
					.font(.footnote)
					.lineLimit(1)
				Spacer()
				if let reset = resetText {
					Text(reset)
						.font(.footnote)
						.foregroundStyle(.secondary)
						.lineLimit(1)
				} else if let detail = detailText {
					Text(detail)
						.font(.footnote)
						.foregroundStyle(.secondary)
						.lineLimit(1)
				}
			}

			if paceText != nil || etaText != nil {
				HStack(alignment: .firstTextBaseline) {
					if let pace = paceText {
						Text(pace)
							.font(.footnote)
							.foregroundStyle(.primary)
							.lineLimit(1)
					}
					Spacer()
					if let eta = etaText {
						Text(eta)
							.font(.footnote)
							.foregroundStyle(.secondary)
							.lineLimit(1)
					}
				}
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.animation(.easeInOut(duration: 0.3), value: percent)
	}
}

#Preview {
	VStack(spacing: 12) {
		UsageProgressBar(
			title: "5-hour usage",
			percent: 0.73,
			percentLabel: "27% left",
			detailText: "Resets in 2h 14m",
			tint: .green
		)
		UsageProgressBar(
			title: "Weekly",
			percent: 0.33,
			percentLabel: "67% left",
			tint: .green,
			resetText: "Resets in 4d 2h",
			paceText: "3% in deficit",
			etaText: "Runs out in 4d 5h",
			paceStage: .concerning
		)
		UsageProgressBar(
			title: "Daily usage",
			percent: 0.85,
			percentLabel: "15% left",
			detailText: "Resets tomorrow",
			tint: .orange
		)
		UsageProgressBar(
			title: "Monthly limit",
			percent: 1.1,
			percentLabel: "Exceeded",
			detailText: "Resets Apr 1"
		)
	}
	.padding(16)
	.frame(width: 280)
}
