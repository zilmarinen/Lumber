// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lumber",
//    platforms: [.macOS(.v14),
//                .iOS(.v17)],
    products: [.library(name: "Lumber",
                        targets: ["Lumber"]),
    ],
    dependencies: [
        .package(url: "git@github.com:nicklockwood/Euclid.git",
                 branch: "develop"),
    ],
    targets: [
        .target(name: "Lumber",
                dependencies: ["Euclid"]),
        .testTarget(name: "LumberTests",
                    dependencies: ["Lumber"]),
    ]
)
