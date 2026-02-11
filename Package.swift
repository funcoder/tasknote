// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TaskNote",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "TaskNote",
            path: "Sources/TaskNote"
        )
    ]
)
