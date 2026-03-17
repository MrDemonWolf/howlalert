//
//  PreferencesView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI
import HowlAlertKit

// MARK: - Preferences View

struct PreferencesView: View {
	let apiClient: APIClient

	@StateObject private var prefs = UserPreferences.shared
	@Environment(\.dismiss) private var dismiss

	// MARK: Local editing state

	@State private var tokenEnabled: Bool = false
	@State private var tokenLimit: String = ""
	@State private var sessionEnabled: Bool = false
	@State private var sessionLimit: String = ""

	// MARK: Save feedback

	@State private var isSaving: Bool = false
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
				thresholdSection
				feedbackSection
			}
			.padding(12)

			Divider()

			HStack {
				Spacer()
				Button("Cancel") { dismiss() }
					.keyboardShortcut(.cancelAction)
				Button("Save") {
					Task { await save() }
				}
				.keyboardShortcut(.defaultAction)
				.disabled(isSaving)
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
				thresholdSection
				feedbackSection
			}
			.navigationTitle("Preferences")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					if isSaving {
						ProgressView()
					} else {
						Button("Save") {
							Task { await save() }
						}
					}
				}
			}
			.onAppear { loadFromPrefs() }
		}
	}
	#endif

	// MARK: - Shared Sub-Views

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

	private func save() async {
		isSaving = true
		saveResult = nil
		defer { isSaving = false }

		let thresholds = buildThresholds()

		// Persist locally
		prefs.thresholds = thresholds

		// Push to API
		do {
			try await apiClient.updatePreferences(thresholds: thresholds)
			saveResult = .success
		} catch {
			saveResult = .failure(error.localizedDescription)
		}
	}
}

#Preview {
	PreferencesView(apiClient: APIClient())
}
