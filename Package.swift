// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZenIoT",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "ZenIoT", targets: ["ZenIoT"]),
        .executable(name: "ZenIoT-Server", targets: ["ZenIoT-Server"]),
        .executable(name: "ZenIoT-Client", targets: ["ZenIoT-Client"])
    ],
    dependencies: [
        .package(url: "https://github.com/gerardogrisolini/ZenNIO.git", .branch("master")),
        .package(url: "https://github.com/gerardogrisolini/ZenPostgres.git", .branch("master")),
        .package(url: "https://github.com/gerardogrisolini/ZenMQTT.git", .branch("master"))
    ],
    targets: [
        .target(name: "ZenIoT", dependencies: ["ZenMQTT"]),
        .target(name: "ZenIoT-Server", dependencies: ["ZenIoT", "ZenNIO", "ZenPostgres"]),
        .target(name: "ZenIoT-Client", dependencies: ["ZenIoT"])
    ],
    swiftLanguageVersions: [.v5]
)
