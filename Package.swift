// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZenNIO-Example",
    dependencies: [
        .package(url: "https://github.com/gerardogrisolini/ZenNIO.git", from: "1.3.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-SQLite.git", from: "3.1.0")
    ],
    targets: [
        .target(
            name: "ZenNIO-Example",
            dependencies: ["ZenNIO", "PerfectSQLite"])
    ]
)
