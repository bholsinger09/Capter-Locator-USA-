// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Common",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Common",
            dependencies: [],
            path: "Sources/Common"
        ),
        .testTarget(
            name: "CommonTests",
            dependencies: ["Common"],
            path: "Tests/CommonTests"
        ),
    ]
)
