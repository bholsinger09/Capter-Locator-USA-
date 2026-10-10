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
        .package(path: "../AppUI"),
    ],
    targets: [
        .target(
            name: "Events",
            dependencies: [
                .product(name: "Common", package: "Common"),
                .product(name: "Chapters", package: "Chapters"),
                .product(name: "AppUI", package: "AppUI"),
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
