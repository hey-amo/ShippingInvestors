// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SI_GameEngine",
    platforms: [
            .macOS(.v10_15),
            .iOS(.v13),
            .watchOS(.v6),
            .tvOS(.v13),
            .visionOS(.v1)
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SI_GameEngine",
            targets: ["SI_GameEngine"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SI_GameEngine"),
        .testTarget(
            name: "SI_GameEngineTests",
            dependencies: ["SI_GameEngine"]
        ),
    ]
)
