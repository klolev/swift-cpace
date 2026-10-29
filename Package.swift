// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-cpace",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift-cpace",
            targets: ["swift_cpace"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jedisct1/swift-sodium.git", from: "0.9.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift_cpace",
            dependencies: [.product(name: "Clibsodium", package: "swift-sodium")],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "swift_cpaceTests",
            dependencies: [.target(name: "swift_cpace")]
        )
    ]
)
