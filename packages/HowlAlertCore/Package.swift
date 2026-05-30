// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HowlAlertCore",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(name: "HowlAlertCore", targets: ["HowlAlertCore"]),
    ],
    targets: [
        .target(name: "HowlAlertCore"),
        .testTarget(name: "HowlAlertCoreTests", dependencies: ["HowlAlertCore"]),
    ]
)
