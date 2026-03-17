//
//  ContentView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI

struct ContentView: View {
	@State private var isDemoMode: Bool = false
	@State private var isMacConfigured: Bool = false

	var body: some View {
		#if os(macOS)
		DashboardView()
		#elseif os(iOS)
		NavigationStack {
			Group {
				if isMacConfigured || isDemoMode {
					DashboardView(isDemo: isDemoMode)
				} else {
					SetupPromptView(showDemo: $isDemoMode)
						.navigationTitle("HowlAlert")
				}
			}
		}
		.task {
			await checkMacConfigured()
		}
		#elseif os(watchOS)
		NavigationStack {
			Group {
				if isMacConfigured || isDemoMode {
					DashboardView(isDemo: isDemoMode)
				} else {
					SetupPromptView(showDemo: $isDemoMode)
				}
			}
		}
		.task {
			await checkMacConfigured()
		}
		#endif
	}

	private func checkMacConfigured() async {
		// Determine whether the API has returned any history data for this user.
		// For now this is a stub — replace with a real API call once the history
		// endpoint is wired up on iOS.
		isMacConfigured = false
	}
}

#Preview {
	ContentView()
}
