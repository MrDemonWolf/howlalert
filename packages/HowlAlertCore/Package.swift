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
        .executable(name: "howlalert-hook", targets: ["howlalert-hook"]),
    ],
    targets: [
        .target(name: "HowlAlertCore"),
        .executableTarget(name: "howlalert-hook", dependencies: ["HowlAlertCore"]),
        .testTarget(name: "HowlAlertCoreTests", dependencies: ["HowlAlertCore"]),
    ]
)
