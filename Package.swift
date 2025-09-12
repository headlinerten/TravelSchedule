// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TravelSchedule",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TravelSchedule",
            targets: ["TravelSchedule"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-openapi-generator.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-runtime.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-urlsession.git",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "TravelSchedule",
            dependencies: [
                .product(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
    ]
)
