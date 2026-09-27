// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Notifications",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Notifications",
            targets: ["Notifications"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../Authentication"),
    ],
    targets: [
        .target(
            name: "Notifications",
            dependencies: [
                .product(name: "Common", package: "Common"),
                .product(name: "Authentication", package: "Authentication"),
            ],
            path: "Sources/Notifications"
        ),
        .testTarget(
            name: "NotificationsTests",
            dependencies: ["Notifications"],
            path: "Tests/NotificationsTests"
        ),
    ]
)
