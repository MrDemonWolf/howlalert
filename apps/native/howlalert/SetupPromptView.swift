//
//  SetupPromptView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI

struct SetupPromptView: View {
	@Binding var showDemo: Bool

	private let learnMoreURL = URL(string: "https://howlalert.dev/docs/getting-started/installation")!

	var body: some View {
		VStack(spacing: 24) {
			Spacer()

			Image(systemName: "bell.badge")
				.font(.system(size: 56))
				.foregroundStyle(.tint)

			VStack(spacing: 8) {
				Text("HowlAlert is ready!")
					.font(.title2)
					.fontWeight(.semibold)

				Text("To start monitoring, open HowlAlert\non your Mac. It reads your Claude Code\nusage directly from ~/.claude/")
					.font(.body)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
			}

			HStack(spacing: 12) {
				Button("View Demo") {
					showDemo = true
				}
				.buttonStyle(.borderedProminent)

				Link(destination: learnMoreURL) {
					HStack(spacing: 4) {
						Text("Learn More")
						Image(systemName: "arrow.right")
							.imageScale(.small)
					}
				}
				.buttonStyle(.bordered)
			}

			Spacer()
		}
		.padding()
	}
}

#Preview {
	SetupPromptView(showDemo: .constant(false))
}
