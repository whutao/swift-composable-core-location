// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swift-composable-core-location",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "ComposableCoreLocation", targets: ["ComposableCoreLocation"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-case-paths",
            from: Version(1, 3, 0)
        ),
        .package(
            url: "https://github.com/whutao/swift-combine-extras",
            from: Version(1, 0, 0)
        ),
        .package(
            url: "https://github.com/whutao/swift-composable-permissions",
            from: Version(1, 0, 0)
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: Version(1, 2, 0)
        )
    ],
    targets: [
        .target(name: "ComposableCoreLocation", dependencies: [
            .product(name: "CasePaths", package: "swift-case-paths"),
            .product(name: "CombineExtras", package: "swift-combine-extras"),
            .product(name: "ComposableLocationPermission", package: "swift-composable-permissions"),
            .product(name: "ComposablePermission", package: "swift-composable-permissions"),
            .product(name: "Dependencies", package: "swift-dependencies"),
            .product(name: "DependenciesMacros", package: "swift-dependencies")
        ])
    ]
)
