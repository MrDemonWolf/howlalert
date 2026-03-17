//
//  DashboardView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI
import HowlAlertKit

// MARK: - Dashboard View

struct DashboardView: View {
	let apiClient: APIClient

	@StateObject private var prefs = UserPreferences.shared
	@State private var usageState: UsageState = .empty
	@State private var isLoading: Bool = false
	@State private var errorMessage: String?
	@State private var showPreferences: Bool = false

	#if os(macOS)
	private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
	#endif

	var body: some View {
		#if os(macOS)
		macDashboard
			.onReceive(timer) { _ in
				Task { await loadData() }
			}
			.onAppear {
				Task { await loadData() }
			}
		#elseif os(iOS)
		iOSDashboard
			.onAppear {
				Task { await loadData() }
			}
		#elseif os(watchOS)
		watchDashboard
			.onAppear {
				Task { await loadData() }
			}
		#endif
	}

	// MARK: - macOS Layout

	#if os(macOS)
	private var macDashboard: some View {
		VStack(spacing: 0) {
			headerBar

			Divider()

			VStack(spacing: 12) {
				if isLoading && usageState == .empty {
					ProgressView("Loading…")
						.padding()
				} else {
					statsSection
					thresholdStatusSection
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

			footerBar
		}
		.frame(width: 280)
	}
	#endif

	// MARK: - iOS Layout

	#if os(iOS)
	private var iOSDashboard: some View {
		NavigationStack {
			List {
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
					} else {
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

	private var headerBar: some View {
		HStack {
			Image(systemName: "bell.badge.fill")
				.foregroundStyle(.tint)
			Text("HowlAlert")
				.font(.headline)
			Spacer()
			if isLoading {
				ProgressView()
					.controlSize(.small)
			} else {
				Button {
					Task { await loadData() }
				} label: {
					Image(systemName: "arrow.clockwise")
						.font(.caption)
				}
				.buttonStyle(.plain)
			}
		}
		.padding(.horizontal, 12)
		.padding(.vertical, 8)
	}

	private var footerBar: some View {
		HStack {
			Text(lastUpdatedText)
				.font(.caption2)
				.foregroundStyle(.tertiary)
			Spacer()
			Button("Settings") {
				showPreferences = true
			}
			.font(.caption)
			.buttonStyle(.plain)
			.foregroundStyle(.tint)
		}
		.padding(.horizontal, 12)
		.padding(.vertical, 6)
		.sheet(isPresented: $showPreferences) {
			PreferencesView(apiClient: apiClient)
		}
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

	private func loadData() async {
		isLoading = true
		errorMessage = nil
		defer { isLoading = false }

		do {
			#if os(macOS)
			if let url = StatsCacheParser.defaultURL() {
				let cache = try StatsCacheParser.parse(from: url)
				usageState = UsageState(
					dailyCost: cache.totalCost ?? 0,
					totalInputTokens: cache.totalTokens ?? 0,
					totalOutputTokens: 0,
					activeSessions: cache.sessionCount ?? 0,
					lastUpdated: Date(),
					recentEvents: []
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

#Preview {
	DashboardView(apiClient: APIClient())
}
