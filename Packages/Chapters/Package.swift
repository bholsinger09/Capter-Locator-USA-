// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Chapters",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Chapters",
            targets: ["Chapters"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../Authentication"),
    ],
    targets: [
        .target(
            name: "Chapters",
            dependencies: [
                .product(name: "Common", package: "Common"),
                .product(name: "Authentication", package: "Authentication"),
            ],
            path: "Sources/Chapters"
        ),
        .testTarget(
            name: "ChaptersTests",
            dependencies: ["Chapters"],
            path: "Tests/ChaptersTests"
        ),
    ]
)
