import SwiftUI
import HowlAlertKit

struct PreferencesView: View {
	// Claude Plan section
	@AppStorage("selectedPlan") private var selectedPlan = "pro"

	// Notification thresholds
	@AppStorage("threshold60") private var threshold60 = true
	@AppStorage("threshold85") private var threshold85 = true
	@AppStorage("threshold100") private var threshold100 = true

	// Demo mode
	@AppStorage("isDemoMode") private var isDemoMode = false

	// Worker URL
	@AppStorage("workerURL") private var workerURL = "https://howlalert-worker.mrdemonwolf.workers.dev"

	// Remote config
	@ObservedObject var configService: RemoteConfigService

	// Dismiss
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			Form {
				// Section 1: Claude Plan
				Section {
					Picker("Plan", selection: $selectedPlan) {
						Text("Free").tag("free")
						Text("Pro").tag("pro")
						Text("Max 5x").tag("max5")
						Text("Max 20x").tag("max20")
					}
				} header: {
					Text("Claude Plan")
				}

				// Section 2: Notification Thresholds
				Section {
					Toggle("Alert at 60% (Approaching)", isOn: $threshold60)
					Toggle("Alert at 85% (Close to limit)", isOn: $threshold85)
					Toggle("Alert at 100% (Limit hit)", isOn: $threshold100)
				} header: {
					Text("Notifications")
				}

				// Section 3: Demo Mode
				Section {
					Toggle("Demo Mode", isOn: $isDemoMode)
				} header: {
					Text("Demo Mode")
				} footer: {
					Text("Shows sample data instead of live usage. Useful for testing or Apple review.")
				}

				// Section 4: Worker Configuration
				Section {
					TextField("Worker URL", text: $workerURL)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
						.keyboardType(.URL)
				} header: {
					Text("Worker")
				}

				// Section 5: Remote Config Status
				Section {
					if let config = configService.currentConfig {
						LabeledContent("Multiplier", value: "\(config.multiplier, specifier: "%.1f")x")
						LabeledContent("Reason", value: config.reason)
						LabeledContent("Last Updated", value: config.updatedAt.formatted())
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
				} header: {
					Text("Remote Config")
				}

				// Section 6: About
				Section {
					LabeledContent("Version", value: Bundle.main.shortVersion)
					LabeledContent("Build", value: Bundle.main.buildNumber)
					Link("Documentation", destination: URL(string: "https://howlalert.com/docs")!)
					Link("Privacy Policy", destination: URL(string: "https://howlalert.com/privacy")!)
				} header: {
					Text("About")
				}
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Done") {
						dismiss()
					}
				}
			}
		}
	}
}

// MARK: - Bundle Extension

#if !os(macOS)
extension Bundle {
	var shortVersion: String {
		infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
	}

	var buildNumber: String {
		infoDictionary?["CFBundleVersion"] as? String ?? "1"
	}
}
#endif
