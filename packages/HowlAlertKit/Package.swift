// swift-tools-version: 5.9

import PackageDescription

let package = Package(
	name: "HowlAlertKit",
	platforms: [
		.macOS(.v14),
		.iOS(.v17),
		.watchOS(.v10),
	],
	products: [
		.library(
			name: "HowlAlertKit",
			targets: ["HowlAlertKit"]
		),
	],
	targets: [
		.target(
			name: "HowlAlertKit",
			path: "Sources"
		),
		.testTarget(
			name: "HowlAlertKitTests",
			dependencies: ["HowlAlertKit"],
			path: "Tests"
		),
	]
)
