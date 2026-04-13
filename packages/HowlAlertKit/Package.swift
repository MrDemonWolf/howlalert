// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HowlAlertKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "HowlAlertKit",
            targets: ["Models", "TokenMath", "ColorState", "PaceEngine", "Config"]
        )
    ],
    targets: [
        .target(
            name: "Models",
            path: "Sources/Models"
        ),
        .target(
            name: "TokenMath",
            dependencies: ["Models"],
            path: "Sources/TokenMath"
        ),
        .target(
            name: "ColorState",
            dependencies: ["Models"],
            path: "Sources/ColorState"
        ),
        .target(
            name: "PaceEngine",
            dependencies: ["Models", "TokenMath", "ColorState"],
            path: "Sources/PaceEngine"
        ),
        .target(
            name: "Config",
            dependencies: ["Models"],
            path: "Sources/Config"
        ),
        .testTarget(
            name: "TokenMathTests",
            dependencies: ["TokenMath"],
            path: "Tests/TokenMathTests"
        ),
        .testTarget(
            name: "ColorStateTests",
            dependencies: ["ColorState"],
            path: "Tests/ColorStateTests"
        )
    ]
)
