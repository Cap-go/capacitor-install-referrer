// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapgoCapacitorInstallReferrer",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CapgoCapacitorInstallReferrer",
            targets: ["InstallReferrerPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "InstallReferrerPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/InstallReferrerPlugin",
            linkerSettings: [
                .linkedFramework("AdServices")
            ]),
        .testTarget(
            name: "InstallReferrerPluginTests",
            dependencies: ["InstallReferrerPlugin"],
            path: "ios/Tests/InstallReferrerPluginTests")
    ]
)
