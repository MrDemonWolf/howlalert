//
//  DashboardView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI
import Combine
import HowlAlertKit
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

// MARK: - Dashboard View

struct DashboardView: View {
	var isDemo: Bool = false

	@StateObject private var prefs = UserPreferences.shared
	@State private var usageState: UsageState = .empty
	@State private var isLoading: Bool = false
	@State private var errorMessage: String?
	@State private var showPreferences: Bool = false

	#if os(macOS)
	@State private var snapshot: ProviderSnapshot?
	@State private var hoveredFooterItem: String?
	private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
	#endif

	var body: some View {
		#if os(macOS)
		macDashboard
			.onReceive(timer) { _ in
				guard !isDemo else { return }
				loadData()
			}
			.onAppear {
				#if canImport(WatchConnectivity)
				WatchConnectivityManager.shared.activate()
				#endif
				if isDemo {
					loadDemoData()
				} else {
					loadData()
				}
			}
		#elseif os(iOS)
		iOSDashboard
			.onAppear {
				WatchConnectivityManager.shared.activate()
				guard !isDemo else { loadDemoData(); return }
				loadData()
			}
		#elseif os(watchOS)
		watchDashboard
			.onAppear {
				guard !isDemo else { loadDemoData(); return }
				loadData()
			}
		#endif
	}

	// MARK: - macOS Layout

	#if os(macOS)
	private var macDashboard: some View {
		VStack(spacing: 0) {
			// Header
			HStack {
				Text("Claude")
					.font(.headline)
				Spacer()
				Text(prefs.selectedPlan.displayName)
					.font(.caption)
					.fontWeight(.medium)
					.padding(.horizontal, 8)
					.padding(.vertical, 2)
					.background(.quaternary, in: Capsule())
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 8)

			HStack {
				Text(lastUpdatedText)
					.font(.caption)
					.foregroundStyle(.secondary)
				Spacer()
				if isLoading {
					ProgressView()
						.controlSize(.small)
				}
			}
			.padding(.horizontal, 12)
			.padding(.bottom, 8)

			Divider()

			// Content
			VStack(spacing: 12) {
				if isDemo {
					demoBanner
				}

				if isLoading && usageState == .empty {
					ProgressView("Loading\u{2026}")
						.padding()
				} else {
					macUsageBars
				}

				if let err = errorMessage {
					Text(err)
						.font(.caption)
						.foregroundStyle(.red)
						.padding(.horizontal)
				}
			}
			.padding(12)

			Divider()

			// Cost section
			CostSectionView(
				todayCost: usageState.dailyCost,
				todayTokens: usageState.totalTokens,
				last30DaysCost: nil,
				last30DaysTokens: nil
			)
			.padding(12)

			Divider()

			// Footer
			VStack(spacing: 0) {
				SettingsLink {
					HStack(spacing: 6) {
						Image(systemName: "gear").frame(width: 16).imageScale(.small)
						Text("Settings\u{2026}")
						Spacer()
					}
					.foregroundStyle(.primary)
					.padding(.horizontal, 12)
					.padding(.vertical, 5)
					.contentShape(Rectangle())
					.background(hoveredFooterItem == "settings" ? Color.primary.opacity(0.08) : .clear, in: RoundedRectangle(cornerRadius: 4))
				}
				.buttonStyle(.plain)
				.onHover { hovering in hoveredFooterItem = hovering ? "settings" : nil }

				macFooterRow(id: "about", icon: "info.circle", label: "About HowlAlert") {
					NSApplication.shared.orderFrontStandardAboutPanel(nil)
				}

				macFooterRow(id: "quit", icon: "xmark.circle", label: "Quit") {
					NSApplication.shared.terminate(nil)
				}
			}
			.padding(.vertical, 4)
		}
		.frame(width: 300)
	}

	@ViewBuilder
	private var macUsageBars: some View {
		if let snap = snapshot, let session = snap.primary {
			// Rate windows available
			UsageProgressBar(
				title: session.label,
				percent: session.percentUsed,
				percentLabel: String(format: "%.0f%% left", session.percentRemaining * 100),
				detailText: "",
				tint: .green,
				resetText: session.resetText,
				paceStage: session.pace?.stage
			)

			if let weekly = snap.weekly {
				UsageProgressBar(
					title: weekly.label,
					percent: weekly.percentUsed,
					percentLabel: String(format: "%.0f%% left", weekly.percentRemaining * 100),
					detailText: "",
					tint: .blue,
					resetText: weekly.resetText,
					paceText: weekly.pace?.paceText,
					etaText: weekly.pace?.etaDescription,
					paceStage: weekly.pace?.stage
				)
			}
		} else {
			// Fallback: threshold-based bars
			let tokenLimit = prefs.thresholds
				.first(where: { $0.type == .tokenCount && $0.isEnabled })?.value ?? 100_000
			let tokenPercent = tokenLimit > 0 ? Double(usageState.totalTokens) / tokenLimit : 0
			let tokenRemaining = max(0, 1.0 - tokenPercent)

			UsageProgressBar(
				title: "Tokens",
				percent: tokenPercent,
				percentLabel: String(format: "%.0f%% left", tokenRemaining * 100),
				detailText: "\(formatTokens(usageState.totalTokens)) / \(formatTokens(Int(tokenLimit)))",
				tint: .green
			)

			let sessionLimit = prefs.thresholds
				.first(where: { $0.type == .sessionCount && $0.isEnabled })?.value ?? 10
			let sessionPercent = sessionLimit > 0 ? Double(usageState.activeSessions) / sessionLimit : 0
			let sessionRemaining = max(0, 1.0 - sessionPercent)

			UsageProgressBar(
				title: "Sessions",
				percent: sessionPercent,
				percentLabel: String(format: "%.0f%% left", sessionRemaining * 100),
				detailText: "\(usageState.activeSessions) / \(Int(sessionLimit))",
				tint: .blue
			)
		}
	}

	private func macFooterRow(id: String, icon: String, label: String, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			HStack(spacing: 6) {
				Image(systemName: icon).frame(width: 16).imageScale(.small)
				Text(label)
				Spacer()
			}
			.foregroundStyle(.primary)
			.padding(.horizontal, 12)
			.padding(.vertical, 5)
			.contentShape(Rectangle())
			.background(hoveredFooterItem == id ? Color.primary.opacity(0.08) : .clear, in: RoundedRectangle(cornerRadius: 4))
		}
		.buttonStyle(.plain)
		.onHover { hovering in hoveredFooterItem = hovering ? id : nil }
	}
	#endif

	// MARK: - iOS Layout

	#if os(iOS)
	private var iOSDashboard: some View {
		NavigationStack {
			List {
				if isDemo {
					Section { demoBanner }
				}

				Section("Rate Limits") {
					let tokenLimit = prefs.thresholds
						.first(where: { $0.type == .tokenCount && $0.isEnabled })?.value ?? 100_000
					let tokenPercent = tokenLimit > 0 ? Double(usageState.totalTokens) / tokenLimit : 0
					let tokenRemaining = max(0, 1.0 - tokenPercent)

					UsageProgressBar(
						title: "Tokens",
						percent: tokenPercent,
						percentLabel: String(format: "%.0f%% left", tokenRemaining * 100),
						detailText: "\(formatTokens(usageState.totalTokens)) / \(formatTokens(Int(tokenLimit)))",
						tint: .green
					)

					let sessionLimit = prefs.thresholds
						.first(where: { $0.type == .sessionCount && $0.isEnabled })?.value ?? 10
					let sessionPercent = sessionLimit > 0 ? Double(usageState.activeSessions) / sessionLimit : 0
					let sessionRemaining = max(0, 1.0 - sessionPercent)

					UsageProgressBar(
						title: "Sessions",
						percent: sessionPercent,
						percentLabel: String(format: "%.0f%% left", sessionRemaining * 100),
						detailText: "\(usageState.activeSessions) / \(Int(sessionLimit))",
						tint: .blue
					)
				}

				Section("Cost") {
					HStack {
						Text("Today")
						Spacer()
						Text(String(format: "$%.2f \u{00b7} %@ tokens", usageState.dailyCost, formatTokens(usageState.totalTokens)))
							.foregroundStyle(.secondary)
					}
					HStack {
						Text("Last 30 Days")
						Spacer()
						Text("\u{2014}")
							.foregroundStyle(.secondary)
					}
				}

				Section("Your Plan") {
					HStack {
						Text("Claude \(prefs.selectedPlan.displayName)")
						Spacer()
						Text(String(format: "$%.0f/mo", prefs.selectedPlan.monthlyPrice))
							.foregroundStyle(.secondary)
					}
				}

				if let err = errorMessage {
					Section {
						Text(err)
							.foregroundStyle(.red)
							.font(.caption)
					}
				}
			}
			.navigationTitle("HowlAlert")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button { showPreferences = true } label: {
						Label("Settings", systemImage: "gear")
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					if isLoading {
						ProgressView()
					} else if !isDemo {
						Button {
							loadData()
						} label: {
							Label("Refresh", systemImage: "arrow.clockwise")
						}
					}
				}
			}
			.sheet(isPresented: $showPreferences) {
				PreferencesView()
			}
			.refreshable {
				guard !isDemo else { return }
				loadData()
			}
		}
	}
	#endif

	// MARK: - watchOS Layout

	#if os(watchOS)
	private var watchDashboard: some View {
		ScrollView {
			VStack(spacing: 16) {
				if isDemo {
					Text("Demo")
						.font(.caption2)
						.foregroundStyle(.orange)
				}

				// Concentric rings
				ZStack {
					// Outer ring track - Session (green)
					Circle()
						.stroke(.green.opacity(0.2), lineWidth: 10)
						.frame(width: 100, height: 100)

					// Outer ring - Session
					Circle()
						.trim(from: 0, to: sessionPercent)
						.stroke(.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
						.rotationEffect(.degrees(-90))
						.frame(width: 100, height: 100)

					// Inner ring track - Weekly (blue)
					Circle()
						.stroke(.blue.opacity(0.2), lineWidth: 10)
						.frame(width: 76, height: 76)

					// Inner ring - Weekly
					Circle()
						.trim(from: 0, to: weeklyPercent)
						.stroke(.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
						.rotationEffect(.degrees(-90))
						.frame(width: 76, height: 76)
				}

				// Labels
				HStack(spacing: 16) {
					Label("Session", systemImage: "circle.fill")
						.font(.caption2)
						.foregroundStyle(.green)
					Label("Weekly", systemImage: "circle.fill")
						.font(.caption2)
						.foregroundStyle(.blue)
				}

				// Cost
				Text(String(format: "$%.2f today", usageState.dailyCost))
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			.padding()
		}
		.navigationTitle("HowlAlert")
	}

	private var sessionPercent: Double {
		let limit = prefs.thresholds.first(where: { $0.type == .tokenCount && $0.isEnabled })?.value ?? 100_000
		return min(Double(usageState.totalTokens) / max(limit, 1), 1.0)
	}

	private var weeklyPercent: Double {
		let limit = prefs.thresholds.first(where: { $0.type == .sessionCount && $0.isEnabled })?.value ?? 10
		return min(Double(usageState.activeSessions) / max(limit, 1), 1.0)
	}
	#endif

	// MARK: - Shared Sub-Views

	private var demoBanner: some View {
		HStack {
			Image(systemName: "exclamationmark.circle.fill")
				.foregroundStyle(.orange)
			Text("Demo \u{2014} connect your Mac to see live data")
				.font(.caption)
				.foregroundStyle(.orange)
		}
		.padding(.horizontal, 12)
		.padding(.vertical, 6)
		.background(.orange.opacity(0.1), in: Capsule())
	}

	// MARK: - Data Loading

	private func loadDemoData() {
		usageState = UsageState(
			dailyCost: DemoData.dailyCost,
			totalInputTokens: DemoData.tokensUsed,
			totalOutputTokens: 0,
			activeSessions: DemoData.sessionCount,
			lastUpdated: Date(),
			recentEvents: []
		)
		#if os(macOS)
		snapshot = ProviderSnapshot(
			providerName: "Claude",
			planName: prefs.selectedPlan.displayName,
			updatedAt: Date(),
			todayCost: DemoData.dailyCost,
			todayTokens: DemoData.tokensUsed
		)
		#endif
	}

	private func loadData() {
		isLoading = true
		errorMessage = nil

		do {
			#if os(macOS)
			try SandboxedFileAccess.shared.resolveAndAccess { claudeURL in
				usageState = ConversationScanner.scan(from: claudeURL)
				snapshot = ProviderSnapshot(
					providerName: "Claude",
					planName: prefs.selectedPlan.displayName,
					updatedAt: Date(),
					todayCost: usageState.dailyCost,
					todayTokens: usageState.totalTokens
				)
				CloudSyncManager.shared.saveUsageState(usageState, plan: prefs.selectedPlan)
			}
			#else
			if let today = CloudSyncManager.shared.fetchTodayUsage() {
				usageState = UsageState(
					dailyCost: today.totalCostUSD,
					totalInputTokens: today.totalInputTokens,
					totalOutputTokens: today.totalOutputTokens,
					activeSessions: today.sessionCount,
					lastUpdated: today.updatedAt,
					recentEvents: []
				)
			}
			#endif

			// Relay updated stats to Apple Watch
			#if canImport(WatchConnectivity) && (os(macOS) || os(iOS))
			let tokenLimit = prefs.thresholds
				.first(where: { $0.type == .tokenCount && $0.isEnabled })
				.map { Int($0.value) } ?? 200_000
			let sessionLimit = prefs.thresholds
				.first(where: { $0.type == .sessionCount && $0.isEnabled })
				.map { Int($0.value) } ?? 10
			WatchConnectivityManager.shared.sendStats(
				tokensUsed: usageState.totalTokens,
				tokenLimit: tokenLimit,
				sessionCount: usageState.activeSessions,
				sessionLimit: sessionLimit
			)
			#endif
		} catch {
			errorMessage = error.localizedDescription
		}

		isLoading = false
	}

	// MARK: - Helpers

	private func formatTokens(_ count: Int) -> String {
		if count >= 1_000_000 {
			return String(format: "%.1fM", Double(count) / 1_000_000)
		} else if count >= 1_000 {
			return String(format: "%.1fK", Double(count) / 1_000)
		}
		return "\(count)"
	}

	private var lastUpdatedText: String {
		guard usageState.lastUpdated != .distantPast else { return "Not loaded" }
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .abbreviated
		return "Updated \(formatter.localizedString(for: usageState.lastUpdated, relativeTo: Date()))"
	}
}

// MARK: - ThresholdType Display

private extension ThresholdType {
	var displayName: String {
		switch self {
		case .dailyCost: "Daily Cost"
		case .tokenCount: "Token Count"
		case .sessionCount: "Session Count"
		}
	}
}

#Preview("Live") {
	DashboardView()
}

#Preview("Demo") {
	DashboardView(isDemo: true)
}
