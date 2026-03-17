//
//  DashboardView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI

struct DashboardView: View {
	var isDemo: Bool = false

	@State private var tokensUsed: Int = 0
	@State private var tokenLimit: Int = 0
	@State private var sessionCount: Int = 0
	@State private var sessionLimit: Int = 0
	@State private var projectName: String = ""
	@State private var lastUpdated: String = ""
	@State private var refreshTimer: Timer?

	private var tokenProgress: Double {
		guard tokenLimit > 0 else { return 0 }
		return Double(tokensUsed) / Double(tokenLimit)
	}

	private var sessionProgress: Double {
		guard sessionLimit > 0 else { return 0 }
		return Double(sessionCount) / Double(sessionLimit)
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 16) {
				if isDemo {
					HStack {
						Image(systemName: "exclamationmark.circle.fill")
							.foregroundStyle(.orange)
						Text("Demo — connect your Mac to see live data")
							.font(.caption)
							.foregroundStyle(.orange)
					}
					.padding(.horizontal, 12)
					.padding(.vertical, 6)
					.background(.orange.opacity(0.1), in: Capsule())
				}

				VStack(alignment: .leading, spacing: 4) {
					Text(projectName)
						.font(.title2)
						.fontWeight(.semibold)
					Text("Last updated: \(lastUpdated)")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				.frame(maxWidth: .infinity, alignment: .leading)

				VStack(alignment: .leading, spacing: 8) {
					HStack {
						Text("Tokens Used")
							.font(.subheadline)
							.fontWeight(.medium)
						Spacer()
						Text("\(tokensUsed.formatted()) / \(tokenLimit.formatted())")
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}
					ProgressView(value: tokenProgress)
						.tint(tokenProgress > 0.9 ? .red : tokenProgress > 0.7 ? .orange : .tint)
				}
				.padding()
				.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

				VStack(alignment: .leading, spacing: 8) {
					HStack {
						Text("Sessions")
							.font(.subheadline)
							.fontWeight(.medium)
						Spacer()
						Text("\(sessionCount) / \(sessionLimit)")
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}
					ProgressView(value: sessionProgress)
						.tint(sessionProgress > 0.9 ? .red : sessionProgress > 0.7 ? .orange : .tint)
				}
				.padding()
				.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
			}
			.padding()
		}
		.navigationTitle("Dashboard")
		.onAppear {
			loadData()
			if !isDemo {
				startRefreshTimer()
			}
		}
		.onDisappear {
			refreshTimer?.invalidate()
			refreshTimer = nil
		}
	}

	private func loadData() {
		if isDemo {
			tokensUsed = DemoData.tokensUsed
			tokenLimit = DemoData.tokenLimit
			sessionCount = DemoData.sessionCount
			sessionLimit = DemoData.sessionLimit
			projectName = DemoData.projectName
			lastUpdated = DemoData.lastUpdated
		} else {
			// TODO: fetch live data from API / local files
			projectName = "my-project"
			lastUpdated = "Never"
		}
	}

	private func startRefreshTimer() {
		refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
			loadData()
		}
	}
}

#Preview("Live") {
	NavigationStack {
		DashboardView()
	}
}

#Preview("Demo") {
	NavigationStack {
		DashboardView(isDemo: true)
	}
}
