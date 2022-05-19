// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PasscodeView",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "PasscodeView",
            targets: ["PasscodeView"]),
    ],
    targets: [
        .target(
            name: "PasscodeView",
            dependencies: [])
    ]
)
