// swift-tools-version:6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BirdBot",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)],
    products: [
        .executable(name: "BirdBot", targets: ["BirdBot"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.25.0"),
        .package(url: "https://github.com/apple/swift-configuration.git", from: "1.0.0", traits: [.defaults, "CommandLineArguments"]),
    ],
    targets: [
        .executableTarget(name: "BirdBot",
            dependencies: [
                .product(name: "Configuration", package: "swift-configuration"),
                .product(name: "Hummingbird", package: "hummingbird"),
            ],
            path: "Sources/App"
        ),
        .testTarget(name: "BirdBotTests",
            dependencies: [
                .byName(name: "BirdBot"),
                .product(name: "HummingbirdTesting", package: "hummingbird"),
            ],
            path: "Tests/AppTests"
        )
    ]
)
