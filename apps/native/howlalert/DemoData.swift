//
//  DemoData.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import Foundation

enum DemoData {
	static let projectName = "acme-webapp"
	static let tokensUsed = 145_230
	static let tokenLimit = 200_000
	static let sessionCount = 7
	static let sessionLimit = 10
	static let dailyCost = 3.47
	static let lastUpdated = "Today at 2:34 PM"

	// For dashboard display
	static let tokenProgress: Double = Double(tokensUsed) / Double(tokenLimit)  // ~0.73
	static let sessionProgress: Double = Double(sessionCount) / Double(sessionLimit) // 0.7

	static let recentEvents: [(name: String, tokens: Int, time: String)] = [
		("Refactor auth middleware", 42_100, "2:34 PM"),
		("Add unit tests for parser", 31_500, "1:15 PM"),
		("Fix pagination bug", 18_200, "12:02 PM"),
		("Update API docs", 28_930, "10:45 AM"),
		("Debug CI pipeline", 24_500, "9:30 AM"),
	]
}
