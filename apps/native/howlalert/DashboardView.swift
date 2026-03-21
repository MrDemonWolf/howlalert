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
	var apiClient: APIClient = APIClient()
	var isDemo: Bool = false

	@StateObject private var prefs = UserPreferences.shared
	@State private var usageState: UsageState = .empty
	@State private var isLoading: Bool = false
	@State private var errorMessage: String?
	@State private var showPreferences: Bool = false

	#if os(macOS)
	@State private var activeSession: ActiveClaudeSession?
	@State private var snapshot: ProviderSnapshot?
	@State private var hoveredFooterItem: String?
	private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
	#endif

	var body: some View {
		#if os(macOS)
		macDashboard
			.onReceive(timer) { _ in
				guard !isDemo else { return }
				Task { await loadData() }
				activeSession = ClaudeSessionReader.readActiveSession()
			}
			.onAppear {
				#if canImport(WatchConnectivity)
				WatchConnectivityManager.shared.activate()
				#endif
				if isDemo {
					loadDemoData()
				} else {
					Task { await loadData() }
					activeSession = ClaudeSessionReader.readActiveSession()
				}
			}
		#elseif os(iOS)
		iOSDashboard
			.onAppear {
				WatchConnectivityManager.shared.activate()
				guard !isDemo else { loadDemoData(); return }
				Task { await loadData() }
			}
		#elseif os(watchOS)
		watchDashboard
			.onAppear {
				guard !isDemo else { loadDemoData(); return }
				Task { await loadData() }
			}
		#endif
	}

	// MARK: - macOS Layout

	#if os(macOS)
	private var macDashboard: some View {
		VStack(spacing: 0) {
			macHeaderSection

			Divider()

			VStack(spacing: 12) {
				if isDemo {
					demoBanner
				}

				if isLoading && usageState == .empty && snapshot == nil {
					ProgressView("Loading\u{2026}")
						.padding()
				} else {
					macRateWindowsSection
					Divider()
					macCostSection
				}

				if let err = errorMessage {
					Text(err)
						.font(.caption)
						.foregroundStyle(.red)
				}
			}
			.padding(12)

			Divider()

			macFooterSection
		}
		.frame(width: 300)
	}

	// MARK: - macOS Header

	private var macHeaderSection: some View {
		VStack(alignment: .leading, spacing: 2) {
			HStack(alignment: .firstTextBaseline) {
				Text(snapshot?.providerName ?? "Claude")
					.font(.headline)
					.fontWeight(.semibold)
				Spacer()
				if let plan = snapshot?.planName {
					Text(plan)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
			}

			HStack(alignment: .firstTextBaseline) {
				Text(lastUpdatedText)
					.font(.footnote)
					.foregroundStyle(.secondary)
				Spacer()
				if isLoading {
					ProgressView()
						.controlSize(.small)
				}
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 10)
	}

	// MARK: - macOS Rate Windows

	private var macRateWindowsSection: some View {
		VStack(spacing: 12) {
			if let primary = snapshot?.primary {
				UsageProgressBar(
					title: primary.label,
					percent: primary.usedPercent / 100.0,
					percentLabel: String(format: "%.0f%% left", primary.remainingPercent),
					resetText: primary.resetText,
					paceText: snapshot?.primaryPace?.paceText,
					etaText: snapshot?.primaryPace?.etaText,
					paceStage: snapshot?.primaryPace?.stage
				)
			} else {
				macFallbackTokenBar
			}

			if let secondary = snapshot?.secondary {
				UsageProgressBar(
					title: secondary.label,
					percent: secondary.usedPercent / 100.0,
					percentLabel: String(format: "%.0f%% left", secondary.remainingPercent),
					resetText: secondary.resetText,
					paceText: snapshot?.secondaryPace?.paceText,
					etaText: snapshot?.secondaryPace?.etaText,
					paceStage: snapshot?.secondaryPace?.stage
				)
			}
		}
	}

	/// Fallback progress bar when no rate windows are available (uses token threshold)
	private var macFallbackTokenBar: some View {
		let tokenThreshold = prefs.thresholds
			.first(where: { $0.type == .tokenCount && $0.isEnabled })
		let limit = tokenThreshold?.value ?? 200_000
		let used = Double(usageState.totalTokens)
		let percent = limit > 0 ? used / limit : 0
		return UsageProgressBar(
			title: "Tokens Today",
			percent: percent,
			percentLabel: "\(formatTokens(usageState.totalTokens)) / \(formatTokens(Int(limit)))",
			tint: .accentColor
		)
	}

	// MARK: - macOS Cost Section

	private var macCostSection: some View {
		CostSectionView(
			todayCost: snapshot?.todayCost ?? usageState.dailyCost,
			todayTokens: snapshot?.todayTokens ?? usageState.totalTokens,
			last30DaysCost: snapshot?.last30DaysCost,
			last30DaysTokens: snapshot?.last30DaysTokens
		)
	}

	// MARK: - macOS Footer

	private var macFooterSection: some View {
		VStack(spacing: 0) {
			macFooterButton(
				id: "settings",
				icon: "gear",
				label: "Settings\u{2026}"
			) {
				showPreferences = true
			}

			macFooterButton(
				id: "about",
				icon: "info.circle",
				label: "About HowlAlert"
			) {
				NSApplication.shared.orderFrontStandardAboutPanel(nil)
			}

			macFooterButton(
				id: "quit",
				icon: "xmark.circle",
				label: "Quit"
			) {
				NSApplication.shared.terminate(nil)
			}
		}
		.sheet(isPresented: $showPreferences) {
			PreferencesView(apiClient: apiClient)
		}
	}

	private func macFooterButton(
		id: String,
		icon: String,
		label: String,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
			HStack(spacing: 8) {
				Image(systemName: icon)
					.font(.footnote)
					.frame(width: 16, alignment: .center)
				Text(label)
					.font(.footnote)
				Spacer()
			}
			.contentShape(Rectangle())
			.padding(.horizontal, 16)
			.padding(.vertical, 6)
			.background(
				RoundedRectangle(cornerRadius: 4, style: .continuous)
					.fill(hoveredFooterItem == id ? Color.primary.opacity(0.08) : Color.clear)
			)
		}
		.buttonStyle(.plain)
		.onHover { isHovered in
			hoveredFooterItem = isHovered ? id : nil
		}
	}
	#endif

	// MARK: - iOS Layout

	#if os(iOS)
	private var iOSDashboard: some View {
		NavigationStack {
			List {
				if isDemo {
					Section {
						demoBanner
							.listRowBackground(Color.orange.opacity(0.05))
					}
				}
				Section("Today's Usage") {
					statsSection
				}
				Section("Threshold Status") {
					thresholdStatusSection
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
					Button {
						showPreferences = true
					} label: {
						Label("Settings", systemImage: "gear")
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					if isLoading {
						ProgressView()
					} else if !isDemo {
						Button {
							Task { await loadData() }
						} label: {
							Label("Refresh", systemImage: "arrow.clockwise")
						}
					}
				}
			}
			.sheet(isPresented: $showPreferences) {
				PreferencesView(apiClient: apiClient)
			}
			.refreshable {
				guard !isDemo else { return }
				await loadData()
			}
		}
	}
	#endif

	// MARK: - watchOS Layout

	#if os(watchOS)
	private var watchDashboard: some View {
		ScrollView {
			VStack(spacing: 8) {
				if isDemo {
					Text("Demo")
						.font(.caption2)
						.foregroundStyle(.orange)
				}
				statRow(label: "Tokens", value: formatTokens(usageState.totalTokens))
				statRow(label: "Sessions", value: "\(usageState.activeSessions)")
				thresholdIndicator
			}
			.padding()
		}
		.navigationTitle("HowlAlert")
	}
	#endif

	// MARK: - Shared Sub-Views

	private var demoBanner: some View {
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


	private var statsSection: some View {
		VStack(spacing: 8) {
			statRow(
				label: "Tokens Today",
				value: formatTokens(usageState.totalTokens)
			)
			statRow(
				label: "Sessions Today",
				value: "\(usageState.activeSessions)"
			)
		}
	}

	private var thresholdStatusSection: some View {
		VStack(spacing: 6) {
			ForEach(prefs.thresholds.filter { $0.isEnabled && $0.type != .dailyCost }) { threshold in
				thresholdRow(threshold)
			}
		}
	}

	private var thresholdIndicator: some View {
		let status = overallThresholdStatus
		return Circle()
			.fill(status.color)
			.frame(width: 16, height: 16)
			.overlay(
				Circle().stroke(status.color.opacity(0.3), lineWidth: 4)
			)
	}

	private func statRow(label: String, value: String) -> some View {
		HStack {
			Text(label)
				.font(.subheadline)
				.foregroundStyle(.secondary)
			Spacer()
			Text(value)
				.font(.subheadline)
				.fontWeight(.medium)
		}
	}

	private func thresholdRow(_ threshold: AlertThreshold) -> some View {
		let status = thresholdStatus(for: threshold)
		return HStack(spacing: 6) {
			Circle()
				.fill(status.color)
				.frame(width: 8, height: 8)
			Text(threshold.type.displayName)
				.font(.caption)
				.foregroundStyle(.secondary)
			Spacer()
			Text(status.label)
				.font(.caption)
				.foregroundStyle(status.color)
		}
	}

	// MARK: - Threshold Logic

	private enum ThresholdStatus {
		case ok, warning, exceeded

		var color: Color {
			switch self {
			case .ok: .green
			case .warning: .yellow
			case .exceeded: .red
			}
		}

		var label: String {
			switch self {
			case .ok: "OK"
			case .warning: "Near limit"
			case .exceeded: "Exceeded"
			}
		}
	}

	private func thresholdStatus(for threshold: AlertThreshold) -> ThresholdStatus {
		let current: Double
		switch threshold.type {
		case .tokenCount:
			current = Double(usageState.totalTokens)
		case .sessionCount:
			current = Double(usageState.activeSessions)
		case .dailyCost:
			current = usageState.dailyCost
		}
		let ratio = threshold.value > 0 ? current / threshold.value : 0
		if ratio >= 1.0 { return .exceeded }
		if ratio >= 0.8 { return .warning }
		return .ok
	}

	private var overallThresholdStatus: ThresholdStatus {
		let statuses = prefs.thresholds
			.filter { $0.isEnabled }
			.map { thresholdStatus(for: $0) }
		if statuses.contains(.exceeded) { return .exceeded }
		if statuses.contains(.warning) { return .warning }
		return .ok
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
		activeSession = ActiveClaudeSession(
			projectPath: "/Users/demo/\(DemoData.projectName)",
			projectName: DemoData.projectName,
			lastActiveDate: Date()
		)
		snapshot = ProviderSnapshot(
			providerName: "Claude",
			planName: "Max",
			updatedAt: Date(),
			primary: nil,
			secondary: nil,
			todayCost: DemoData.dailyCost,
			todayTokens: DemoData.tokensUsed,
			last30DaysCost: 91.23,
			last30DaysTokens: 2_100_000
		)
		#endif
	}

	private func loadData() async {
		isLoading = true
		errorMessage = nil
		defer { isLoading = false }

		do {
			#if os(macOS)
			if let url = StatsCacheParser.defaultURL() {
				let cache = try StatsCacheParser.parse(from: url)
				let cost = cache.totalCost ?? 0
				let tokens = cache.totalTokens ?? 0
				let sessions = cache.sessionCount ?? 0
				usageState = UsageState(
					dailyCost: cost,
					totalInputTokens: tokens,
					totalOutputTokens: 0,
					activeSessions: sessions,
					lastUpdated: Date(),
					recentEvents: []
				)
				// Populate snapshot from cache — rate windows will be nil until
				// ClaudeUsageFetcher is built; dashboard shows fallback bars.
				snapshot = ProviderSnapshot(
					providerName: "Claude",
					planName: nil,
					updatedAt: Date(),
					primary: nil,
					secondary: nil,
					todayCost: cost,
					todayTokens: tokens
				)
			}
			#else
			let events = try await apiClient.getHistory(limit: 50)
			let todayEvents = events.filter { Calendar.current.isDateInToday($0.timestamp) }
			let totalTokens = todayEvents.reduce(0) { $0 + $1.inputTokens + $1.outputTokens }
			let totalCost = todayEvents.reduce(0.0) { $0 + $1.costUSD }
			usageState = UsageState(
				dailyCost: totalCost,
				totalInputTokens: totalTokens,
				totalOutputTokens: 0,
				activeSessions: Set(todayEvents.compactMap { $0.sessionId }).count,
				lastUpdated: Date(),
				recentEvents: todayEvents
			)
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
	DashboardView(apiClient: APIClient())
}

#Preview("Demo") {
	DashboardView(isDemo: true)
}
