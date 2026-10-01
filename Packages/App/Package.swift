// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "App",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "SwiftChapterUSA_finder",
            targets: ["App"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../AppUI"),
        .package(path: "../Authentication"),
        .package(path: "../Chapters"),
        .package(path: "../Events"),
        .package(path: "../Geospatial"),
        .package(path: "../Advocacy"),
        .package(path: "../Resources"),
        .package(path: "../Notifications"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Common", package: "Common"),
                .product(name: "AppUI", package: "AppUI"),
                .product(name: "Authentication", package: "Authentication"),
                .product(name: "Chapters", package: "Chapters"),
                .product(name: "Events", package: "Events"),
                .product(name: "Geospatial", package: "Geospatial"),
                .product(name: "Advocacy", package: "Advocacy"),
                .product(name: "Resources", package: "Resources"),
                .product(name: "Notifications", package: "Notifications"),
            ],
            path: "Sources/App"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"],
            path: "Tests/AppTests"
        ),
    ]
)
