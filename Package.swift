// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftChapterUSA",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(path: "Packages/Common"),
        .package(path: "Packages/App"),
        .package(path: "Packages/Authentication"),
        .package(path: "Packages/Chapters"),
        .package(path: "Packages/Events"),
        .package(path: "Packages/Geospatial"),
        .package(path: "Packages/Advocacy"),
        .package(path: "Packages/Resources"),
        .package(path: "Packages/Notifications"),
        .package(path: "Packages/AppUI"),
    ]
)
