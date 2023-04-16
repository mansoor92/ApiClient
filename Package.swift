// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ApiClient",
    platforms: [.iOS("13.0")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ApiClient",
            targets: ["ApiClient"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ApiClient",
            dependencies: []
        ),
        .testTarget(
            name: "ApiClientTests",
            dependencies: ["ApiClient"]),
    ]
)
