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
        .package(path: "../AppUI"),
    ],
    targets: [
        .target(
            name: "Chapters",
            dependencies: [
                .product(name: "Common", package: "Common"),
                .product(name: "Authentication", package: "Authentication"),
                .product(name: "AppUI", package: "AppUI"),
            ],
            path: "Sources/Chapters",
            resources: [
                .process("Resources/")
            ]
        ),
        .testTarget(
            name: "ChaptersTests",
            dependencies: ["Chapters"],
            path: "Tests/ChaptersTests"
        ),
    ]
)

