// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Advocacy",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Advocacy",
            targets: ["Advocacy"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
    ],
    targets: [
        .target(
            name: "Advocacy",
            dependencies: [
                .product(name: "Common", package: "Common"),
            ],
            path: "Sources/Advocacy"
        ),
        .testTarget(
            name: "AdvocacyTests",
            dependencies: ["Advocacy"],
            path: "Tests/AdvocacyTests"
        ),
    ]
)
