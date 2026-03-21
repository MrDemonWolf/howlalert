//
//  UsageProgressBar.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI
import HowlAlertKit

struct UsageProgressBar: View {
	let title: String
	let percent: Double          // 0.0 to 1.0
	let percentLabel: String     // "66% left"
	let detailText: String       // "145.2K / 200.0K"
	var tint: Color = .accentColor
	var resetText: String? = nil   // "Resets in 2h 58m"
	var paceText: String? = nil    // "3% in deficit"
	var etaText: String? = nil     // "Runs out in 4d 5h"
	var paceStage: UsagePace.Stage? = nil

	private var barColor: Color {
		switch paceStage {
		case .comfortable, .onTrack:
			return tint
		case .moderate:
			return .yellow
		case .concerning:
			return .orange
		case .critical:
			return .red
		case nil:
			return percent >= 1.0 ? .red : tint
		}
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack {
				Text(title)
					.font(.subheadline)
					.fontWeight(.medium)
				Spacer()
				Text(detailText)
					.font(.caption)
					.foregroundStyle(.secondary)
			}

			GeometryReader { geometry in
				ZStack(alignment: .leading) {
					RoundedRectangle(cornerRadius: 3)
						.fill(Color.primary.opacity(0.1))
						.frame(height: 6)

					RoundedRectangle(cornerRadius: 3)
						.fill(barColor)
						.frame(width: max(0, geometry.size.width * min(percent, 1.0)), height: 6)
				}
			}
			.frame(height: 6)

			HStack {
				Text(percentLabel)
					.font(.caption)
					.foregroundStyle(.secondary)
				Spacer()
				if let resetText = resetText {
					Text(resetText)
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}

			if paceText != nil || etaText != nil {
				HStack {
					if let paceText = paceText {
						Text(paceText)
							.font(.caption)
							.foregroundStyle(.orange)
					}
					Spacer()
					if let etaText = etaText {
						Text(etaText)
							.font(.caption)
							.foregroundStyle(.orange)
					}
				}
			}
		}
	}
}

#Preview {
	VStack(spacing: 20) {
		UsageProgressBar(
			title: "Session",
			percent: 0.34,
			percentLabel: "66% left",
			detailText: "145.2K / 200.0K",
			tint: .green,
			resetText: "Resets in 2h 58m"
		)

		UsageProgressBar(
			title: "Weekly",
			percent: 0.33,
			percentLabel: "67% left",
			detailText: "1.2M / 3.6M",
			tint: .blue,
			resetText: "Resets in 4d 5h",
			paceText: "3% in deficit",
			etaText: "Runs out 4d 5h",
			paceStage: .moderate
		)
	}
	.padding()
	.frame(width: 280)
}
