// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-effect-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Effect Primitives",
            targets: ["Effect Primitives"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-test-primitives"),
        .package(path: "../swift-dependency-primitives"),
    ],
    targets: [
        .target(
            name: "Effect Primitives",
            dependencies: [
                .product(name: "Dependency Primitives", package: "swift-dependency-primitives"),
            ]
        ),
        .testTarget(
            name: "Effect Primitives Tests",
            dependencies: [
                "Effect Primitives",
                .product(name: "Test Primitives", package: "swift-test-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
