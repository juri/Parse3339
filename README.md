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

```
Parse with DateFormatter
╒════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                     │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Malloc (total)             │     275 │     275 │     275 │     275 │     275 │     275 │     279 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (M) │      11 │      15 │      19 │      23 │      25 │      27 │      27 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (K)     │      17 │      16 │      16 │      16 │      15 │      12 │       1 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (ns)      │   59084 │   59967 │   60255 │   61887 │   64927 │   82175 │  236750 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (ns)     │   58500 │   59391 │   59647 │   61279 │   64255 │   83327 │  513167 │  100000 │
╘════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Parse with ISO8601DateFormatter
╒════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                     │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Malloc (total)             │     496 │     496 │     496 │     496 │     496 │     496 │     497 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K) │    9764 │    9781 │    9781 │    9781 │    9781 │    9781 │    9781 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (K)     │      11 │      10 │      10 │      10 │      10 │       7 │       0 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (ns)      │   91375 │   92351 │   92799 │   95551 │   99519 │  123007 │  542458 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (ns)     │   90792 │   91711 │   92159 │   94911 │   98879 │  127487 │ 3553542 │  100000 │
╘════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Parse with Parse3339 (DateComponents)
╒════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                     │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Malloc (total)             │      64 │      64 │      64 │      64 │      64 │      64 │      67 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (M) │       9 │      41 │      73 │     105 │     124 │     136 │     137 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (K)     │      43 │      42 │      42 │      41 │      38 │      29 │       4 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (ns)      │   23416 │   23999 │   24223 │   25007 │   26463 │   34751 │  206791 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (ns)     │   22833 │   23423 │   23631 │   24383 │   25807 │   34335 │  211458 │  100000 │
╘════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Parse with Parse3339 (Unix time)
╒════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                     │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Malloc (total)             │       0 │       0 │       0 │       0 │       0 │       0 │       0 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K) │    7831 │    7852 │    7864 │    7864 │    7864 │    7864 │    7864 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (K)     │     263 │     252 │     247 │     242 │     233 │     183 │      17 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (ns)      │    4333 │    4503 │    4543 │    4667 │    4875 │    6543 │   48584 │  100000 │
├────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (ns)     │    3791 │    3959 │    4041 │    4127 │    4291 │    5459 │   56625 │  100000 │
╘════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛
```
