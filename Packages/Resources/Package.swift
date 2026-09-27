// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Resources",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Resources",
            targets: ["Resources"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
    ],
    targets: [
        .target(
            name: "Resources",
            dependencies: [
                .product(name: "Common", package: "Common"),
            ],
            path: "Sources/Resources"
        ),
        .testTarget(
            name: "ResourcesTests",
            dependencies: ["Resources"],
            path: "Tests/ResourcesTests"
        ),
    ]
)
