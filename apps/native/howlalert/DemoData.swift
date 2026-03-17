//
//  DemoData.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import Foundation

enum DemoData {
	static let projectName = "my-project"
	static let tokensUsed = 145_230
	static let tokenLimit = 200_000
	static let sessionCount = 7
	static let sessionLimit = 10
	static let lastUpdated = "Today at 2:34 PM"

	// For dashboard display
	static let tokenProgress: Double = Double(tokensUsed) / Double(tokenLimit)  // ~0.73
	static let sessionProgress: Double = Double(sessionCount) / Double(sessionLimit) // 0.7
}
