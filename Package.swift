// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZenNIO-Example",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .executable(name: "ZenNIO-Example", targets: ["ZenNIO-Example"])
    ],
    dependencies: [
        .package(url: "https://github.com/gerardogrisolini/ZenNIO.git", .branch("master")),
        .package(url: "https://github.com/gerardogrisolini/ZenPostgres.git", .branch("master")),
        .package(url: "https://github.com/gerardogrisolini/ZenUI.git", .branch("master")),
    ],
    targets: [
        .target(name: "ZenNIO-Example", dependencies: ["ZenNIO", "ZenPostgres", "ZenUI"])
    ],
    swiftLanguageVersions: [.v5]
)
