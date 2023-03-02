// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Obsy",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Obsy",
            targets: ["Obsy"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-atomics.git",
            .upToNextMajor(from: "1.0.0")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Obsy",
            dependencies: [
                .product(name: "Atomics", package: "swift-atomics")
            ]),
        .testTarget(
            name: "ObsyTests",
            dependencies: ["Obsy"]),
    ]
)
