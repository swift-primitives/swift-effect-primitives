// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-effect-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Effect Primitives",
            targets: ["Effect Primitives"]
        ),
        .library(
            name: "Effect Primitives Test Support",
            targets: ["Effect Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-dependency-primitives"),
        .package(path: "../swift-equation-primitives"),
        .package(path: "../swift-hash-primitives"),
    ],
    targets: [
        .target(
            name: "Effect Primitives",
            dependencies: [
                .product(name: "Dependency Primitives", package: "swift-dependency-primitives"),
                .product(name: "Equation Primitives", package: "swift-equation-primitives"),
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
            ]
        ),
        .target(
            name: "Effect Primitives Test Support",
            dependencies: [
                "Effect Primitives",
                .product(name: "Hash Primitives Test Support", package: "swift-hash-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Effect Primitives Tests",
            dependencies: [
                "Effect Primitives",
                "Effect Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
