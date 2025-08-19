// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bloc",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .macOS(.v10_15)
        ],
    products: [
        .library(
            name: "Bloc",
            targets: ["Bloc"]
        ),
    ],
    targets: [
        .target(
            name: "Bloc"
        ),
        .testTarget(
            name: "BlocTests",
            dependencies: ["Bloc"]
        ),
    ]
)
