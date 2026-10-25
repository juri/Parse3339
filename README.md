[![Build](https://github.com/juri/Parse3339/actions/workflows/build.yml/badge.svg)](https://github.com/juri/Parse3339/actions/workflows/build.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjuri%2FParse3339%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/juri/Parse3339)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjuri%2FParse3339%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/juri/Parse3339)

# Parse3339

Parse3339 is a fast [RFC 3339] time stamp parser written in pure Swift.

RFC 3339 specifies the commonly used subset of ISO 8601 suitable for time stamps. This parser restricts the subset even further. The following are the formats supported by Parse3339:

- `2023-07-09T13:14:00+03:00`
- `2023-07-09T13:14:00.2+03:00`
- `2023-07-09T13:14:00Z`
- `2023-07-09T13:14:00.2Z`

There's nothing to configure, and it's all in just file in case you want to copy it over instead of using it as a package.

[RFC 3339]: https://www.rfc-editor.org/rfc/rfc3339

## Usage

```swift
import Parse3339

let s = "2023-07-09T13:14:00+03:00"
guard let parts = Parse3339::parse(s) else {
    return
}
let date = parts.date
print(date.timeIntervalSinceReferenceDate)
// output: 710590440.0
```

There are variants of `parse` for `String`, `Substring` and `Span<UInt8>`. By default `parse` parses the start of the string and allows trailing data. If you don't want to allow trailing data, you can specify `requireFullConsumption`:

```swift
Parse3339::parse(s, requireFullConsumption: true)
```

There's a helper function you can use with Foundation's `JSONDecoder`:

```swift
import Parse3339

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .custom(Parse3339::parseFromDecoder(_:))
```

Parse3339 ships with Foundation integration (`Date`, `DateComponents`) enabled by default, but they can be disabled by disabling the `WithFoundation` trait. The parsing itself uses only Swift standard library types.

For `Package.swift` snippets and documentation, visit the [Swift Package Index page](https://swiftpackageindex.com/juri/Parse3339).

## Speed and memory usage

Parse3339 is pleasantly fast and stingy with memory usage. The package has benchmarks:

```sh
swift package benchmark
```

To measure parsing without date conversion, run the parser-only benchmarks:

```sh
swift package benchmark --filter 'Parse with Parse3339 \((String|Span) only\)' --metric wallClock --metric throughput --scale
```

These benchmarks use 8,192 timestamps with varying dates, fractional precision, and time zones. They measure the `String` and byte-span entry points separately.

There are also benchmarks that parse the same string using Foundation's `DateFormatter`, Foundation's `ISO8601DateFormatter`, Parse3339 creating a `Date` with Foundation's `DateComponents` and `Calendar`, and Parse3339 creating a `Date` with standard Unix functions.

Output from one run (macOS 27.0.1, MacBook Pro M5):

### Parse with DateFormatter

| Metric                         |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:-------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| Free (total) *                 |      1061 |      1061 |      1061 |      1061 |      1061 |      1061 |      1063 |    100000 |
| Instructions (K) *             |      2161 |      2163 |      2163 |      2163 |      2163 |      2179 |      2421 |    100000 |
| Malloc (bytes total) *         |    232713 |    232831 |    232831 |    232831 |    232831 |    232831 |    237065 |    100000 |
| Malloc (total) *               |      1063 |      1063 |      1063 |      1063 |      1063 |      1063 |      1067 |    100000 |
| Malloc / free Δ *              |         2 |         2 |         2 |         2 |         2 |         2 |         6 |    100000 |
| Malloc / free Δ (bytes) *      |        99 |        99 |        99 |        99 |        99 |        99 |      4195 |    100000 |
| Memory (resident peak) (M)     |        17 |        21 |        25 |        29 |        31 |        32 |        32 |    100000 |
| Throughput (# / s) (K)         |        12 |        11 |        11 |        11 |        11 |         9 |         6 |    100000 |
| Time (total CPU) (ns) *        |     87918 |     94271 |     94847 |     95423 |     96639 |    107711 |    176791 |    100000 |
| Time (wall clock) (ns) *       |     86750 |     92927 |     93503 |     94079 |     95167 |    105663 |    178750 |    100000 |

### Parse with ISO8601DateFormatter

| Metric                         |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:-------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| Free (total) *                 |      1239 |      1239 |      1239 |      1239 |      1239 |      1239 |      1239 |    100000 |
| Instructions (K) *             |      2642 |      2642 |      2642 |      2642 |      2642 |      2660 |      2857 |    100000 |
| Malloc (bytes total) *         |    330588 |    330751 |    330751 |    330751 |    330751 |    330751 |    331004 |    100000 |
| Malloc (total) *               |      1239 |      1239 |      1239 |      1239 |      1239 |      1239 |      1245 |    100000 |
| Malloc / free Δ *              |         0 |         0 |         0 |         0 |         0 |         0 |         6 |    100000 |
| Malloc / free Δ (bytes) *      |         0 |         0 |         0 |         0 |         0 |         0 |       416 |    100000 |
| Memory (resident peak) (M)     |        15 |        16 |        16 |        16 |        16 |        16 |        16 |    100000 |
| Throughput (# / s) (#)         |      9012 |      8415 |      8359 |      8303 |      8175 |      7439 |      5318 |    100000 |
| Time (total CPU) (ns) *        |    112375 |    120319 |    121215 |    122047 |    123967 |    135807 |    177208 |    100000 |
| Time (wall clock) (ns) *       |    110958 |    118847 |    119679 |    120575 |    122367 |    134527 |    188042 |    100000 |

### Parse with Parse3339 (DateComponents)

| Metric                         |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:-------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| Free (total) *                 |         1 |         1 |         1 |         1 |         1 |         1 |         1 |    100000 |
| Instructions (K) *             |         6 |         6 |         6 |         6 |         6 |         7 |        60 |    100000 |
| Malloc (bytes total) *         |       153 |       153 |       153 |       153 |       153 |       153 |       153 |    100000 |
| Malloc (total) *               |         1 |         1 |         1 |         1 |         1 |         1 |         1 |    100000 |
| Malloc / free Δ *              |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc / free Δ (bytes) *      |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Memory (resident peak) (M)     |        13 |        13 |        13 |        13 |        13 |        13 |        13 |    100000 |
| Throughput (# / s) (K)         |      1845 |      1500 |      1413 |      1413 |      1411 |      1144 |        54 |    100000 |
| Time (total CPU) (ns) *        |      1749 |      1959 |      2000 |      2042 |      2083 |      2543 |     23667 |    100000 |
| Time (wall clock) (ns) *       |       542 |       667 |       708 |       708 |       709 |       875 |     18584 |    100000 |

### Parse with Parse3339 (Span only)

| Metric                         |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:-------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| Free (total) *                 |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Instructions *                 |       464 |       464 |       464 |       464 |       464 |       464 |       503 |    100000 |
| Malloc (bytes total) *         |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc (total) *               |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc / free Δ *              |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc / free Δ (bytes) *      |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Memory (resident peak) (M)     |        12 |        13 |        13 |        13 |        13 |        13 |        13 |    100000 |
| Throughput (# / s) (M)         |        89 |        82 |        82 |        82 |        81 |        67 |        25 |    100000 |
| Time (total CPU) (ns) *        |        13 |        14 |        14 |        14 |        14 |        17 |        38 |    100000 |
| Time (wall clock) (ns) *       |        11 |        12 |        12 |        12 |        12 |        15 |        40 |    100000 |

### Parse with Parse3339 (String only)

| Metric                         |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:-------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| Free (total) *                 |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Instructions *                 |       525 |       525 |       525 |       525 |       525 |       525 |       573 |    100000 |
| Malloc (bytes total) *         |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc (total) *               |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc / free Δ *              |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc / free Δ (bytes) *      |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Memory (resident peak) (M)     |        12 |        13 |        13 |        13 |        13 |        13 |        13 |    100000 |
| Throughput (# / s) (M)         |        68 |        62 |        62 |        61 |        60 |        51 |        16 |    100000 |
| Time (total CPU) (ns) *        |        16 |        17 |        18 |        18 |        18 |        22 |        57 |    100000 |
| Time (wall clock) (ns) *       |        15 |        16 |        16 |        16 |        17 |        20 |        62 |    100000 |

### Parse with Parse3339 (Unix time)

| Metric                         |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:-------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| Free (total) *                 |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Instructions (K) *             |        54 |        54 |        54 |        54 |        54 |        55 |        70 |    100000 |
| Malloc (bytes total) *         |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc (total) *               |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc / free Δ *              |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Malloc / free Δ (bytes) *      |         0 |         0 |         0 |         0 |         0 |         0 |         0 |    100000 |
| Memory (resident peak) (M)     |        12 |        13 |        13 |        13 |        13 |        13 |        13 |    100000 |
| Throughput (# / s) (K)         |       490 |       445 |       437 |       429 |       429 |       343 |        50 |    100000 |
| Time (total CPU) (ns) *        |      3209 |      3583 |      3625 |      3667 |      3709 |      4583 |     19332 |    100000 |
| Time (wall clock) (ns) *       |      2041 |      2251 |      2291 |      2333 |      2335 |      2917 |     20000 |    100000 |
