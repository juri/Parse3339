// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "Parse3339",
    products: [
        .library(
            name: "Parse3339",
            targets: ["Parse3339"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/benchmark", .upToNextMajor(from: "1.35.0")),
    ],
    targets: [
        .target(name: "Parse3339"),
        .testTarget(
            name: "Parse3339Tests",
            dependencies: ["Parse3339"],
        ),
    ],
)

if ProcessInfo.processInfo.environment["PARSE3339_BENCHMARK"] != nil {
    package.platforms = [.macOS(.v26), .iOS(.v16)]
    package.targets += [
        .executableTarget(
            name: "ParserBenchmarks",
            dependencies: [
                .product(name: "Benchmark", package: "benchmark"),
                "Parse3339",
            ],
            path: "Benchmarks/ParserBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "benchmark"),
            ],
        ),
    ]
}
