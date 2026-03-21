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

	// MARK: Save feedback

	@State private var saveResult: SaveResult? = nil

	private enum SaveResult {
		case success
		case failure(String)
	}

	var body: some View {
		#if os(macOS)
		macLayout
		#elseif os(iOS)
		iOSLayout
		#endif
	}

	// MARK: - macOS Layout

	#if os(macOS)
	private var macLayout: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack {
				Text("Preferences")
					.font(.headline)
				Spacer()
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark.circle.fill")
						.foregroundStyle(.secondary)
				}
				.buttonStyle(.plain)
			}
			.padding(12)

			Divider()

			VStack(alignment: .leading, spacing: 16) {
				claudePlanSection
				hookSetupSection
				notificationSection
				thresholdSection
				proSection
				generalSection
				feedbackSection
			}
			.padding(12)

			Divider()

			HStack {
				Spacer()
				Button("Cancel") { dismiss() }
					.keyboardShortcut(.cancelAction)
				Button("Save") {
					save()
				}
				.keyboardShortcut(.defaultAction)
			}
			.padding(12)
		}
		.frame(width: 300)
		.onAppear { loadFromPrefs() }
	}
	#endif

	// MARK: - iOS Layout

	#if os(iOS)
	private var iOSLayout: some View {
		NavigationStack {
			Form {
				claudePlanSection
				notificationSection
				thresholdSection
				proSection
				generalSection
				feedbackSection
			}
			.navigationTitle("Preferences")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						save()
					}
				}
			}
			.onAppear { loadFromPrefs() }
		}
	}
	#endif

	// MARK: - Claude Plan Section

	private var claudePlanSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Claude Plan")
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(.secondary)

			VStack(alignment: .leading, spacing: 8) {
				Picker("Plan", selection: $prefs.selectedPlan) {
					ForEach(ClaudePlan.allCases, id: \.self) { plan in
						Text(plan.displayName).tag(plan)
					}
				}
				#if os(macOS)
				.pickerStyle(.menu)
				#endif

				HStack {
					Text("Monthly Price")
					Spacer()
					Text(String(format: "$%.2f", prefs.selectedPlan.monthlyPrice))
						.foregroundStyle(.secondary)
				}
			}
			.padding(10)
			.background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
		}
	}

	// MARK: - Hook Setup Section (macOS only)

	#if os(macOS)
	private var hookSetupSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Claude Code Hook")
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(.secondary)

			VStack(alignment: .leading, spacing: 8) {
				Text("Add a hook to Claude Code for real-time usage tracking.")
					.font(.caption)
					.foregroundStyle(.secondary)

				Button("Copy Hook Command") {
					let hookPath = Bundle.main.path(forResource: "howlalert-hook", ofType: nil) ?? "/Applications/HowlAlert.app/Contents/Resources/howlalert-hook"
					let hookJSON = """
					{
					  "hooks": {
					    "Notification": [{
					      "type": "command",
					      "command": "\(hookPath)"
					    }]
					  }
					}
					"""
					NSPasteboard.general.clearContents()
					NSPasteboard.general.setString(hookJSON, forType: .string)
				}

				Text("Paste into ~/.claude/settings.json")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			.padding(10)
			.background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
		}
	}
	#endif

	// MARK: - Notifications Section

	private var notificationSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Notifications")
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(.secondary)

			Group {
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
			.padding(10)
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
		}
		.task {
			await notificationManager.checkStatus()
		}
	}

	// MARK: - Threshold Section

	private var thresholdSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Alert Thresholds")
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(.secondary)

			// Token count threshold
			VStack(alignment: .leading, spacing: 6) {
				Toggle("Token Count Alert", isOn: $tokenEnabled)
					.toggleStyle(.switch)

				if tokenEnabled {
					HStack {
						Text("Limit")
							.font(.caption)
							.foregroundStyle(.secondary)
						Spacer()
						TextField("e.g. 100000", text: $tokenLimit)
							.multilineTextAlignment(.trailing)
							#if os(iOS)
							.keyboardType(.numberPad)
							#endif
							.frame(width: 120)
					}
					.padding(.leading, 8)
				}
			}
			.padding(10)
			.background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

			// Session count threshold
			VStack(alignment: .leading, spacing: 6) {
				Toggle("Session Count Alert", isOn: $sessionEnabled)
					.toggleStyle(.switch)

				if sessionEnabled {
					HStack {
						Text("Limit")
							.font(.caption)
							.foregroundStyle(.secondary)
						Spacer()
						TextField("e.g. 20", text: $sessionLimit)
							.multilineTextAlignment(.trailing)
							#if os(iOS)
							.keyboardType(.numberPad)
							#endif
							.frame(width: 120)
					}
					.padding(.leading, 8)
				}
			}
			.padding(10)
			.background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
		}
	}

	// MARK: - HowlAlert Pro Section

	private var proSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("HowlAlert Pro")
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(.secondary)

			VStack(alignment: .leading, spacing: 8) {
				Label("Upgrade to Pro", systemImage: "star.fill")
					.foregroundStyle(.orange)
				Text("Widgets, Live Activities, usage history & more")
					.font(.caption)
					.foregroundStyle(.secondary)
				// RevenueCat PaywallView will go here later
				Button("Coming Soon") {}
					.disabled(true)
			}
			.padding(10)
			.background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
		}
	}

	// MARK: - General Section (Demo Mode + Claude Directory on macOS)

	private var generalSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("General")
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(.secondary)

			VStack(alignment: .leading, spacing: 6) {
				Toggle("Demo Mode", isOn: $prefs.isDemoMode)
					.toggleStyle(.switch)
				Text("Show sample data for demonstration purposes")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			.padding(10)
			.background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
		}
	}

	// MARK: - Feedback Section

	@ViewBuilder
	private var feedbackSection: some View {
		switch saveResult {
		case .success:
			HStack(spacing: 6) {
				Image(systemName: "checkmark.circle.fill")
					.foregroundStyle(.green)
				Text("Preferences saved.")
					.font(.caption)
					.foregroundStyle(.green)
			}
		case .failure(let message):
			HStack(spacing: 6) {
				Image(systemName: "xmark.circle.fill")
					.foregroundStyle(.red)
				Text(message)
					.font(.caption)
					.foregroundStyle(.red)
			}
		case .none:
			EmptyView()
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
		saveResult = nil

		let thresholds = buildThresholds()

		// Persist locally
		prefs.thresholds = thresholds
		saveResult = .success
	}
}

#Preview {
	PreferencesView()
}
