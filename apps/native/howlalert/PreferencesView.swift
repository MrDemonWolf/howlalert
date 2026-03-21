//
//  PreferencesView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI
import UserNotifications
import HowlAlertKit
#if os(iOS)
import UIKit
#endif

// MARK: - Preferences View

struct PreferencesView: View {
	@StateObject private var prefs = UserPreferences.shared
	@StateObject private var notificationManager = NotificationManager.shared
	@Environment(\.dismiss) private var dismiss

	// MARK: Local editing state

	@State private var tokenEnabled: Bool = false
	@State private var tokenLimit: String = ""
	@State private var sessionEnabled: Bool = false
	@State private var sessionLimit: String = ""

	var body: some View {
		#if os(macOS)
		macLayout
		#elseif os(iOS)
		iOSLayout
		#endif
	}

	// MARK: - macOS Layout (TabView)

	#if os(macOS)
	private var macLayout: some View {
		TabView {
			generalTab
				.tabItem { Label("General", systemImage: "gear") }
			alertsTab
				.tabItem { Label("Alerts", systemImage: "bell.badge") }
			aboutTab
				.tabItem { Label("About", systemImage: "info.circle") }
		}
		.frame(width: 400, height: 340)
		.onAppear { loadFromPrefs() }
	}

	private var generalTab: some View {
		Form {
			// Claude Plan
			Section("Claude Plan") {
				Picker("Plan", selection: $prefs.selectedPlan) {
					ForEach(ClaudePlan.allCases) { plan in
						Text(plan.displayName).tag(plan)
					}
				}
				.pickerStyle(.menu)

				HStack {
					Text("Monthly Price")
						.foregroundStyle(.secondary)
					Spacer()
					Text(String(format: "$%.0f/mo", prefs.selectedPlan.monthlyPrice))
						.foregroundStyle(.secondary)
				}
				.font(.caption)
			}

			// Claude Code Hook (macOS only)
			Section("Claude Code Hook") {
				Text("Install the hook to send usage events to HowlAlert automatically.")
					.font(.caption)
					.foregroundStyle(.secondary)
				Button("Copy Hook Command") {
					let command = "claude hook install howlalert"
					NSPasteboard.general.clearContents()
					NSPasteboard.general.setString(command, forType: .string)
				}
			}

			// Demo Mode
			Section("General") {
				Toggle("Demo Mode", isOn: $prefs.isDemoMode)
				Text("Show sample data for demonstration purposes")
					.font(.caption)
					.foregroundStyle(.secondary)

				Toggle("Launch at Login", isOn: $prefs.launchAtLogin)
			}
		}
		.formStyle(.grouped)
		.padding()
	}

	private var alertsTab: some View {
		Form {
			// Notifications
			Section("Notifications") {
				notificationStatusRow
			}

			// Alert Thresholds
			Section("Alert Thresholds") {
				Toggle("Token Count Alert", isOn: $tokenEnabled)

				if tokenEnabled {
					HStack {
						Text("Limit")
							.font(.caption)
							.foregroundStyle(.secondary)
						Spacer()
						TextField("e.g. 100000", text: $tokenLimit)
							.multilineTextAlignment(.trailing)
							.frame(width: 120)
					}
					.padding(.leading, 8)
				}

				Divider()

				Toggle("Session Count Alert", isOn: $sessionEnabled)

				if sessionEnabled {
					HStack {
						Text("Limit")
							.font(.caption)
							.foregroundStyle(.secondary)
						Spacer()
						TextField("e.g. 20", text: $sessionLimit)
							.multilineTextAlignment(.trailing)
							.frame(width: 120)
					}
					.padding(.leading, 8)
				}

				Divider()

				HStack {
					Text("Daily Cost Alert")
						.foregroundStyle(.secondary)
					Spacer()
					Text(String(format: "$%.2f", prefs.dailyCostThreshold))
						.foregroundStyle(.secondary)
				}
				.font(.caption)
			}

			HStack {
				Spacer()
				Button("Save Thresholds") {
					save()
				}
				.keyboardShortcut(.defaultAction)
			}
		}
		.formStyle(.grouped)
		.padding()
		.onAppear { loadFromPrefs() }
	}

	private var aboutTab: some View {
		Form {
			Section("HowlAlert") {
				HStack {
					Text("Version")
					Spacer()
					Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
						.foregroundStyle(.secondary)
				}

				if let url = URL(string: "https://howlalert.com") {
					Link("Website", destination: url)
				}

				if let url = URL(string: "https://howlalert.com/privacy") {
					Link("Privacy Policy", destination: url)
				}
			}

			Section("HowlAlert Pro") {
				HStack {
					Image(systemName: "sparkles")
						.foregroundStyle(.secondary)
					Text("Coming Soon")
						.foregroundStyle(.secondary)
				}
			}
		}
		.formStyle(.grouped)
		.padding()
	}
	#endif

	// MARK: - iOS Layout

	#if os(iOS)
	private var iOSLayout: some View {
		NavigationStack {
			Form {
				// Claude Plan
				Section("Claude Plan") {
					Picker("Plan", selection: $prefs.selectedPlan) {
						ForEach(ClaudePlan.allCases) { plan in
							Text(plan.displayName).tag(plan)
						}
					}
					HStack {
						Text("Monthly Price")
						Spacer()
						Text(String(format: "$%.0f/mo", prefs.selectedPlan.monthlyPrice))
							.foregroundStyle(.secondary)
					}
				}

				// Notifications
				Section("Notifications") {
					notificationStatusRow
				}

				// Alert Thresholds
				Section("Alert Thresholds") {
					Toggle("Token Count Alert", isOn: $tokenEnabled)

					if tokenEnabled {
						HStack {
							Text("Limit")
								.foregroundStyle(.secondary)
							Spacer()
							TextField("e.g. 100000", text: $tokenLimit)
								.multilineTextAlignment(.trailing)
								.keyboardType(.numberPad)
								.frame(width: 120)
						}
					}

					Toggle("Session Count Alert", isOn: $sessionEnabled)

					if sessionEnabled {
						HStack {
							Text("Limit")
								.foregroundStyle(.secondary)
							Spacer()
							TextField("e.g. 20", text: $sessionLimit)
								.multilineTextAlignment(.trailing)
								.keyboardType(.numberPad)
								.frame(width: 120)
						}
					}

					HStack {
						Text("Daily Cost Alert")
						Spacer()
						Text(String(format: "$%.2f", prefs.dailyCostThreshold))
							.foregroundStyle(.secondary)
					}
				}

				// Live Activity
				Section("Live Activity") {
					Text("Session vs Weekly display")
						.foregroundStyle(.secondary)
						.font(.caption)
				}

				// HowlAlert Pro
				Section("HowlAlert Pro") {
					HStack {
						Image(systemName: "sparkles")
							.foregroundStyle(.secondary)
						Text("Coming Soon")
							.foregroundStyle(.secondary)
					}
				}

				// General
				Section("General") {
					Toggle("Demo Mode", isOn: $prefs.isDemoMode)
					Text("Show sample data for demonstration purposes")
						.font(.caption)
						.foregroundStyle(.secondary)
				}

				// About
				Section("About") {
					HStack {
						Text("Version")
						Spacer()
						Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
							.foregroundStyle(.secondary)
					}

					if let url = URL(string: "https://howlalert.com") {
						Link("Website", destination: url)
					}

					if let url = URL(string: "https://howlalert.com/privacy") {
						Link("Privacy Policy", destination: url)
					}
				}
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						save()
						dismiss()
					}
				}
			}
			.onAppear { loadFromPrefs() }
		}
	}
	#endif

	// MARK: - Shared Sub-Views

	@ViewBuilder
	private var notificationStatusRow: some View {
		switch notificationManager.authorizationStatus {
		case .authorized:
			HStack(spacing: 6) {
				Image(systemName: "checkmark.circle.fill")
					.foregroundStyle(.green)
				Text("Notifications enabled")
					.font(.caption)
					.foregroundStyle(.green)
			}
		case .denied:
			VStack(alignment: .leading, spacing: 6) {
				HStack(spacing: 6) {
					Image(systemName: "xmark.circle.fill")
						.foregroundStyle(.red)
					Text("Notifications are disabled")
						.font(.caption)
						.foregroundStyle(.red)
				}
				#if os(iOS)
				Button("Open Settings") {
					if let url = URL(string: UIApplication.openSettingsURLString) {
						UIApplication.shared.open(url)
					}
				}
				.font(.caption)
				#else
				Text("Enable in System Settings > Notifications")
					.font(.caption2)
					.foregroundStyle(.secondary)
				#endif
			}
		case .notDetermined:
			Button {
				Task {
					let granted = await notificationManager.requestPermission()
					if granted {
						#if os(iOS)
						await UIApplication.shared.registerForRemoteNotifications()
						#elseif os(macOS)
						NSApplication.shared.registerForRemoteNotifications()
						#endif
					}
				}
			} label: {
				Label("Enable Notifications", systemImage: "bell.badge")
			}
			.font(.caption)
		default:
			HStack(spacing: 6) {
				Image(systemName: "questionmark.circle")
					.foregroundStyle(.secondary)
				Text("Notification status unavailable")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
	}

	// MARK: - Logic

	private func loadFromPrefs() {
		let thresholds = prefs.thresholds

		if let tokenThreshold = thresholds.first(where: { $0.type == .tokenCount }) {
			tokenEnabled = tokenThreshold.isEnabled
			tokenLimit = tokenThreshold.value > 0 ? String(Int(tokenThreshold.value)) : ""
		} else {
			tokenEnabled = false
			tokenLimit = "100000"
		}

		if let sessionThreshold = thresholds.first(where: { $0.type == .sessionCount }) {
			sessionEnabled = sessionThreshold.isEnabled
			sessionLimit = sessionThreshold.value > 0 ? String(Int(sessionThreshold.value)) : ""
		} else {
			sessionEnabled = false
			sessionLimit = "20"
		}
	}

	private func buildThresholds() -> [AlertThreshold] {
		let tokenValue = Double(tokenLimit) ?? 100_000
		let sessionValue = Double(sessionLimit) ?? 20

		var result: [AlertThreshold] = []

		// Preserve daily cost threshold if it exists
		if let existing = prefs.thresholds.first(where: { $0.type == .dailyCost }) {
			result.append(existing)
		}

		result.append(AlertThreshold(
			type: .tokenCount,
			value: tokenValue,
			isEnabled: tokenEnabled
		))

		result.append(AlertThreshold(
			type: .sessionCount,
			value: sessionValue,
			isEnabled: sessionEnabled
		))

		return result
	}

	private func save() {
		prefs.thresholds = buildThresholds()
	}
}

#Preview {
	PreferencesView()
}
