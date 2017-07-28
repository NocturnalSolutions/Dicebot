// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Dicebot",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura-net.git", majorVersion: 1)
    ]
)
