// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "HowlAlertKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
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
            path: "Sources/HowlAlertKit"
        ),
        .testTarget(
            name: "HowlAlertKitTests",
            dependencies: ["HowlAlertKit"],
            path: "Tests/HowlAlertKitTests"
        ),
    ]
)
