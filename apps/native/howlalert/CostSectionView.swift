//
//  CostSectionView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

#if os(macOS)
import SwiftUI

struct CostSectionView: View {
	let todayCost: Double
	let todayTokens: Int
	let last30DaysCost: Double?
	let last30DaysTokens: Int?

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text("Cost")
				.font(.subheadline)
				.fontWeight(.medium)
			Text("Today: \(String(format: "$%.2f", todayCost)) \u{00b7} \(formatTokens(todayTokens)) tokens")
				.font(.caption)
			if let cost30 = last30DaysCost, let tokens30 = last30DaysTokens {
				Text("Last 30 days: \(String(format: "$%.2f", cost30)) \u{00b7} \(formatTokens(tokens30)) tokens")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
	}

	private func formatTokens(_ count: Int) -> String {
		if count >= 1_000_000 { return String(format: "%.1fM", Double(count) / 1_000_000) }
		if count >= 1_000 { return String(format: "%.1fK", Double(count) / 1_000) }
		return "\(count)"
	}
}

#Preview {
	CostSectionView(
		todayCost: 3.47,
		todayTokens: 145_230,
		last30DaysCost: 91.23,
		last30DaysTokens: 2_100_000
	)
	.padding()
}
#endif
