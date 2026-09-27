// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Geospatial",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Geospatial",
            targets: ["Geospatial"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../Chapters"),
    ],
    targets: [
        .target(
            name: "Geospatial",
            dependencies: [
                .product(name: "Common", package: "Common"),
                .product(name: "Chapters", package: "Chapters"),
            ],
            path: "Sources/Geospatial"
        ),
        .testTarget(
            name: "GeospatialTests",
            dependencies: ["Geospatial"],
            path: "Tests/GeospatialTests"
        ),
    ]
)
