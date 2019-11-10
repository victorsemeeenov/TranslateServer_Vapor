// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TranslationServer",
    products: [
        .library(name: "TranslationServer", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver", from: "1.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

