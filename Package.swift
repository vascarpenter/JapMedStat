// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JapMedStat",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),

        .package(url: "https://github.com/IBM-Swift/Swift-Kuery.git", from: "3.0.1"),
        .package(url: "https://github.com/IBM-Swift/SwiftKueryMySQL.git", from: "2.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "JapMedStat",
            dependencies: ["SwiftKuery", "SwiftKueryMySQL"]),
        .testTarget(
            name: "JapMedStatTests",
            dependencies: ["JapMedStat"]),
    ]
)
