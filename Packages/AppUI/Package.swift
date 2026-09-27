// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AppUI",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AppUI",
            targets: ["AppUI"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
    ],
    targets: [
        .target(
            name: "AppUI",
            dependencies: [
                .product(name: "Common", package: "Common"),
            ],
            path: "Sources/AppUI"
        ),
        .testTarget(
            name: "AppUITests",
            dependencies: ["AppUI"],
            path: "Tests/AppUITests"
        ),
    ]
)
