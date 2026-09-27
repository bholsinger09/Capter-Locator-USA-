// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Authentication",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Authentication",
            targets: ["Authentication"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
    ],
    targets: [
        .target(
            name: "Authentication",
            dependencies: [
                .product(name: "Common", package: "Common"),
            ],
            path: "Sources/Authentication"
        ),
        .testTarget(
            name: "AuthenticationTests",
            dependencies: ["Authentication"],
            path: "Tests/AuthenticationTests"
        ),
    ]
)
