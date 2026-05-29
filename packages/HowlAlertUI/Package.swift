// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HowlAlertUI",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(name: "HowlAlertUI", targets: ["HowlAlertUI"]),
    ],
    targets: [
        .target(name: "HowlAlertUI"),
    ]
)
