// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Blogs",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Blogs",
            targets: ["Blogs"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../AppUI"),
    ],
    targets: [
        .target(
            name: "Blogs",
            dependencies: [
                .product(name: "Common", package: "Common"),
                .product(name: "AppUI", package: "AppUI"),
            ],
            path: "Sources/Blogs"
        ),
        .testTarget(
            name: "BlogsTests",
            dependencies: ["Blogs"],
            path: "Tests/BlogsTests"
        ),
    ]
)
