// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HowlAlertKit",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .watchOS(.v11),
    ],
    products: [
        .library(name: "HowlAlertKit", targets: ["HowlAlertKit"]),
    ],
    targets: [
        .target(name: "HowlAlertKit"),
        .testTarget(name: "HowlAlertKitTests", dependencies: ["HowlAlertKit"]),
    ]
)
