//
//  WatchComplication.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

#if os(watchOS)
import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct ComplicationEntry: TimelineEntry {
	var date: Date
	var tokensUsed: Int
	var tokenLimit: Int
}

// MARK: - Timeline Provider

struct ComplicationProvider: TimelineProvider {
	private let appGroupID = "group.com.mrdemonwolf.howlalert"

	func placeholder(in context: Context) -> ComplicationEntry {
		ComplicationEntry(
			date: Date(),
			tokensUsed: DemoData.tokensUsed,
			tokenLimit: DemoData.tokenLimit
		)
	}

	func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> Void) {
		completion(ComplicationEntry(
			date: Date(),
			tokensUsed: DemoData.tokensUsed,
			tokenLimit: DemoData.tokenLimit
		))
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<ComplicationEntry>) -> Void) {
		let defaults = UserDefaults(suiteName: appGroupID) ?? .standard
		let tokensUsed = defaults.integer(forKey: WatchConnectivityManager.tokensUsedKey)
		let tokenLimit = defaults.integer(forKey: WatchConnectivityManager.tokenLimitKey)

		let entry = ComplicationEntry(
			date: Date(),
			tokensUsed: tokensUsed,
			tokenLimit: tokenLimit > 0 ? tokenLimit : DemoData.tokenLimit
		)

		// Refresh every 15 minutes; WatchConnectivity will trigger earlier updates
		let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
		let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
		completion(timeline)
	}
}

// MARK: - Entry View

struct ComplicationEntryView: View {
	var entry: ComplicationEntry

	var body: some View {
		WatchRingView(tokensUsed: entry.tokensUsed, tokenLimit: entry.tokenLimit)
	}
}

// MARK: - Widget

struct HowlAlertComplication: Widget {
	var body: some WidgetConfiguration {
		StaticConfiguration(
			kind: "com.mrdemonwolf.howlalert.complication",
			provider: ComplicationProvider()
		) { entry in
			ComplicationEntryView(entry: entry)
				.containerBackground(.fill.tertiary, for: .widget)
		}
		.configurationDisplayName("HowlAlert")
		.description("Token usage ring")
		.supportedFamilies([.accessoryCircular])
	}
}
#endif
