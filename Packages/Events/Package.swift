// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Events",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Events",
            targets: ["Events"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../Chapters"),
    ],
    targets: [
        .target(
            name: "Events",
            dependencies: [
                .product(name: "Common", package: "Common"),
                .product(name: "Chapters", package: "Chapters"),
            ],
            path: "Sources/Events"
        ),
        .testTarget(
            name: "EventsTests",
            dependencies: ["Events"],
            path: "Tests/EventsTests"
        ),
    ]
)
