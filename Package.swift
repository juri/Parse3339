// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Parse3339",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Parse3339",
            targets: ["Parse3339"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.6.5")),
    ],
    targets: [
        .target(name: "Parse3339"),
        .testTarget(
            name: "Parse3339Tests",
            dependencies: ["Parse3339"]
        ),
    ]
)

// Benchmark of ParserBenchmarks
package.targets += [
    .executableTarget(
        name: "ParserBenchmarks",
        dependencies: [
            .product(name: "Benchmark", package: "package-benchmark"),
            "Parse3339",
        ],
        path: "Benchmarks/ParserBenchmarks",
        plugins: [
            .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
        ]
    ),
]
