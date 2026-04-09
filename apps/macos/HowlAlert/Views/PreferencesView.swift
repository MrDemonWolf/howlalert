import SwiftUI
import HowlAlertKit

struct PreferencesView: View {
	// Claude Plan section
	@AppStorage("selectedPlan") private var selectedPlan = "pro"

	// Notification thresholds
	@AppStorage("threshold60") private var threshold60 = true
	@AppStorage("threshold85") private var threshold85 = true
	@AppStorage("threshold100") private var threshold100 = true

	// Worker URL
	@AppStorage("workerURL") private var workerURL = "https://howlalert-worker.mrdemonwolf.workers.dev"

	// Remote config
	@ObservedObject var configService: RemoteConfigService

	// Clipboard feedback
	@State private var showCopiedFeedback = false

	var body: some View {
		Form {
			// Section 1: Claude Plan
			Section("Claude Plan") {
				Picker("Plan", selection: $selectedPlan) {
					Text("Free").tag("free")
					Text("Pro").tag("pro")
					Text("Max 5x").tag("max5")
					Text("Max 20x").tag("max20")
				}
			}

			// Section 2: Notification Thresholds
			Section("Notifications") {
				Toggle("Alert at 60% (Approaching)", isOn: $threshold60)
				Toggle("Alert at 85% (Close to limit)", isOn: $threshold85)
				Toggle("Alert at 100% (Limit hit)", isOn: $threshold100)
			}

			// Section 3: Hook Setup
			Section("Claude Code Hook") {
				Text("Add a hook to get instant rate limit detection")
					.font(.caption)
					.foregroundStyle(.secondary)
				Button {
					HookHandler.copyHookConfigToClipboard()
					showCopiedFeedback = true
					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						showCopiedFeedback = false
					}
				} label: {
					HStack {
						Text("Copy Hook Config to Clipboard")
						if showCopiedFeedback {
							Image(systemName: "checkmark.circle.fill")
								.foregroundStyle(.green)
						}
					}
				}
				Text("Paste into your .claude/settings.json file")
					.font(.caption2)
					.foregroundStyle(.tertiary)
			}

			// Section 4: Worker Configuration
			Section("Worker") {
				TextField("Worker URL", text: $workerURL)
					.textFieldStyle(.roundedBorder)
			}

			// Section 5: Remote Config Status
			Section("Remote Config") {
				if let config = configService.currentConfig {
					LabeledContent("Multiplier", value: "\(config.multiplier, specifier: "%.1f")x")
					if let promo = config.activePromo {
						LabeledContent("Promo", value: promo.name)
						LabeledContent("Promo Ends", value: promo.endsAt.formatted())
					}
					if let updatedAt = config.updatedAt {
						LabeledContent("Last Updated", value: updatedAt.formatted())
					}
				} else {
					Text("Not fetched yet")
						.foregroundStyle(.secondary)
				}
				if let error = configService.lastFetchError {
					Text(error)
						.font(.caption)
						.foregroundStyle(.red)
				}
				Button("Refresh Now") {
					Task { await configService.refresh() }
				}
			}

			// Section 6: About
			Section("About") {
				LabeledContent("Version", value: Bundle.main.shortVersion)
				LabeledContent("Build", value: Bundle.main.buildNumber)
				Link("Documentation", destination: URL(string: "https://howlalert.com/docs")!)
				Link("Privacy Policy", destination: URL(string: "https://howlalert.com/privacy")!)
			}
		}
		.formStyle(.grouped)
		.frame(width: 400)
	}
}

// MARK: - Bundle Extension

extension Bundle {
	var shortVersion: String {
		infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
	}

	var buildNumber: String {
		infoDictionary?["CFBundleVersion"] as? String ?? "1"
	}
}
