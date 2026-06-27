[![Build](https://github.com/juri/Parse3339/actions/workflows/build.yml/badge.svg)](https://github.com/juri/Parse3339/actions/workflows/build.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjuri%2FParse3339%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/juri/Parse3339)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjuri%2FParse3339%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/juri/Parse3339)

# Parse3339

Parse3339 is a fast [RFC 3339] time stamp parser written in pure Swift.

RFC 3339 specifies the commonly used subset of ISO 8601 suitable for time stamps. This parser restricts the subset even further. The following are the formats supported by Parse3339:

- `2023-07-09T113:14:00+03:00`
- `2023-07-09T113:14:00.2+03:00`
- `2023-07-09T113:14:00Z`
- `2023-07-09T113:14:00.2Z`

There's nothing to configure, and it's all in just file in case you want to copy it over instead of using it as a package.

[RFC 3339]: https://www.rfc-editor.org/rfc/rfc3339

## Usage

```swift
import Parse3339

let s = "2023-07-09T13:14:00+03:00"
guard let parts = Parse3339.parse(s) else {
    return
}
let date = parts.date
print(date.timeIntervalSinceReferenceDate)
// output: 710590440.0
```

There's a helper function you can use with Foundation's `JSONDecoder`:

```swift
import Parse3339

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .custom(Parse3339.parseFromDecoder(_:))
```

For `Package.swift` snippets and documentation, visit the [Swift Package Index page](https://swiftpackageindex.com/juri/Parse3339).

## Speed and memory usage

Parse3339 is pleasantly fast and stingy with memory usage. The package has benchmarks:

```sh
env PARSE3339_BENCHMARK=1 swift package benchmark --target ParserBenchmarks
```

It has benchmarks that parse the same string using Foundation's `DateFormatter`, Foundation's `ISO8601DateFormatter`, Parse3339 creating a `Date` with Foundation's `DateComponents` and `Calendar`, and Parse3339 creating a `Date` with standard Unix functions.

Output from one run:

| Metric                         |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:-------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| Free (total) *                 |       502 |       502 |       502 |       502 |       502 |       502 |       504 |    100000 |
| Instructions (K) *             |      1119 |      1119 |      1119 |      1119 |      1120 |      1133 |      1299 |    100000 |
| Malloc (bytes total) *         |    123663 |    123711 |    123711 |    123711 |    123711 |    123711 |    128015 |    100000 |
| Malloc (total) *               |       504 |       504 |       504 |       504 |       504 |       504 |       508 |    100000 |
| Malloc / free Δ *              |         2 |         2 |         2 |         2 |         2 |         2 |         6 |    100000 |
| Malloc / free Δ (bytes) *      |       176 |       176 |       176 |       176 |       176 |       176 |      4272 |    100000 |
| Memory (resident peak) (M)     |        14 |        21 |        27 |        33 |        36 |        38 |        39 |    100000 |
| Throughput (# / s) (K)         |        23 |        22 |        21 |        21 |        21 |        19 |         8 |    100000 |
| Time (total CPU) (ns) *        |     44208 |     46175 |     48191 |     48735 |     49087 |     55423 |    124708 |    100000 |
| Time (wall clock) (ns) *       |     42958 |     44863 |     46815 |     47359 |     47711 |     53503 |    129750 |    100000 |

### Parse with ISO8601DateFormatter

| Metric                         |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:-------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| Free (total) *                 |       606 |       606 |       606 |       606 |       606 |       606 |       606 |    100000 |
| Instructions (K) *             |      1416 |      1417 |      1417 |      1417 |      1417 |      1436 |      1647 |    100000 |
| Malloc (bytes total) *         |    185038 |    185087 |    185087 |    185087 |    185087 |    185087 |    185454 |    100000 |
| Malloc (total) *               |       606 |       606 |       606 |       606 |       606 |       606 |       612 |    100000 |
| Malloc / free Δ *              |         0 |         0 |         0 |         0 |         0 |         0 |         6 |    100000 |
| Malloc / free Δ (bytes) *      |         0 |         0 |         0 |         0 |         0 |         0 |       416 |    100000 |
| Memory (resident peak) (M)     |        13 |        14 |        14 |        14 |        14 |        14 |        14 |    100000 |
| Throughput (# / s) (K)         |        18 |        17 |        16 |        16 |        16 |        14 |         8 |    100000 |
| Time (total CPU) (ns) *        |     58250 |     61151 |     63359 |     63839 |     64607 |     72895 |    119792 |    100000 |
| Time (wall clock) (ns) *       |     57042 |     59903 |     62047 |     62559 |     63263 |     70783 |    131500 |    100000 |

### Parse with Parse3339 (DateComponents)

| Metric                         |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:-------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| Free (total) *                 |         1 |         1 |         1 |         1 |         1 |         1 |         1 |    100000 |
| Instructions (K) *             |         6 |         6 |         6 |         6 |         7 |         7 |        20 |    100000 |
| Malloc (bytes total) *         |       153 |       153 |       153 |       153 |       153 |       153 |       153 |    100000 |
| Malloc (total) *               |         1 |         1 |         1 |         1 |         1 |         1 |         1 |    100000 |
| Malloc / free Δ *              |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc / free Δ (bytes) *      |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Memory (resident peak) (M)     |        11 |        11 |        11 |        11 |        11 |        11 |        11 |    100000 |
| Throughput (# / s) (K)         |      1715 |      1413 |      1413 |      1334 |      1334 |      1044 |        62 |    100000 |
| Time (total CPU) (ns) *        |      1791 |      2041 |      2083 |      2085 |      2167 |      2709 |     15875 |    100000 |
| Time (wall clock) (ns) *       |       583 |       708 |       708 |       750 |       750 |       958 |     16000 |    100000 |

### Parse with Parse3339 (Unix time)

| Metric                         |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:-------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| Free (total) *                 |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Instructions (K) *             |        54 |        55 |        55 |        55 |        55 |        67 |        80 |    100000 |
| Malloc (bytes total) *         |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc (total) *               |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc / free Δ *              |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc / free Δ (bytes) *      |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Memory (resident peak) (M)     |        11 |        11 |        11 |        11 |        11 |        11 |        11 |    100000 |
| Throughput (# / s) (K)         |       500 |       445 |       436 |       429 |       414 |       329 |        43 |    100000 |
| Time (total CPU) (ns) *        |      3208 |      3541 |      3583 |      3627 |      3709 |      4459 |     21541 |    100000 |
| Time (wall clock) (ns) *       |      2000 |      2251 |      2293 |      2335 |      2417 |      3041 |     23500 |    100000 |
