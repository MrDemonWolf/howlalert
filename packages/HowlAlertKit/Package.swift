// swift-tools-version: 6.0
// HowlAlertKit — Shared logic for HowlAlert
// © 2026 MrDemonWolf, Inc.

import PackageDescription

let package = Package(
    name: "HowlAlertKit",
    platforms: [
        .macOS(.v15),
        .iOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(name: "HowlAlertKit", targets: [
            "Models",
            "TokenMath",
            "ColorState",
            "PaceEngine",
            "Providers",
            "Config",
            "DemoMode",
        ]),
    ],
    targets: [
        // ── Core ────────────────────────────────────────
        .target(name: "Models"),
        .target(name: "Config", dependencies: ["Models"]),

        // ── Math & State ────────────────────────────────
        .target(name: "TokenMath", dependencies: ["Models"]),
        .target(name: "ColorState", dependencies: ["Models"]),
        .target(name: "PaceEngine", dependencies: ["Models", "TokenMath", "ColorState", "Providers"]),

        // ── Providers ───────────────────────────────────
        .target(name: "Providers", dependencies: ["Models"]),

        // ── Demo ────────────────────────────────────────
        .target(name: "DemoMode", dependencies: ["Models", "TokenMath", "ColorState"]),

        // ── Tests ───────────────────────────────────────
        .testTarget(name: "TokenMathTests", dependencies: ["TokenMath", "Models"]),
        .testTarget(name: "ColorStateTests", dependencies: ["ColorState", "Models"]),
        .testTarget(name: "ProviderTests", dependencies: ["Providers", "Models"]),
    ]
)
