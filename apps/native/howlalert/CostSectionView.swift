//
//  CostSectionView.swift
//  howlalert
//
//  Created for HAA-10: CodexBar-style layout redesign
//

#if os(macOS)
import SwiftUI

/// macOS-only cost section showing today's and last 30 days' cost + token counts.
struct CostSectionView: View {
	let todayCost: Double?
	let todayTokens: Int?
	let last30DaysCost: Double?
	let last30DaysTokens: Int?

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text("Cost")
				.font(.body)
				.fontWeight(.medium)

			Text(todayLine)
				.font(.footnote)

			Text(monthLine)
				.font(.footnote)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private var todayLine: String {
		let cost = todayCost.map { formatCost($0) } ?? "--"
		let tokens = todayTokens.map { formatTokens($0) }
		if let tokens {
			return "Today: \(cost) \u{00B7} \(tokens) tokens"
		}
		return "Today: \(cost)"
	}

	private var monthLine: String {
		let cost = last30DaysCost.map { formatCost($0) } ?? "--"
		let tokens = last30DaysTokens.map { formatTokens($0) }
		if let tokens {
			return "Last 30 days: \(cost) \u{00B7} \(tokens) tokens"
		}
		return "Last 30 days: \(cost)"
	}

	private func formatCost(_ value: Double) -> String {
		String(format: "$%.2f", value)
	}

	private func formatTokens(_ count: Int) -> String {
		if count >= 1_000_000 {
			return String(format: "%.1fM", Double(count) / 1_000_000)
		} else if count >= 1_000 {
			return String(format: "%.1fK", Double(count) / 1_000)
		}
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
	.padding(16)
	.frame(width: 280)
}
#endif
