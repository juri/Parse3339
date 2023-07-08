[![Build](https://github.com/juri/Parse3339/actions/workflows/build.yml/badge.svg)](https://github.com/juri/Parse3339/actions/workflows/build.yml)

# Parse3339

Parse3339 is a fast [RFC 3339] time stamp parser written in pure Swift.

There's nothing to configure, and it's all in just file in case you want to copy it over instead of using it as a package.

[RFC 3339]: https://www.rfc-editor.org/rfc/rfc3339

## Speed and memory usage

Parse3339 is pleasantly fast and stingy with memory usage. The package has benchmarks:

```sh
swift package benchmark --target ParserBenchmarks
```

It has benchmarks that parse the same string using Foundation's `DateFormatter`, Foundation's `ISO8601DateFormatter`, Parse3339 creating a `Date` with Foundation's `DateComponents` and `Calendar`, and Parse3339 creating a `Date` with standard Unix functions.

Output from one run:

### Parse with DateFormatter

| Metric                     |      p0 |     p25 |     p50 |     p75 |     p90 |     p99 |    p100 | Samples |
|----------------------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Malloc (total)             |     275 |     275 |     275 |     275 |     275 |     275 |     279 |  100000 |
| Memory (resident peak) (M) |      11 |      15 |      19 |      23 |      25 |      27 |      27 |  100000 |
| Throughput (# / s) (K)     |      16 |      16 |      16 |      16 |      16 |      14 |       5 |  100000 |
| Time (total CPU) (μs)      |      60 |      61 |      61 |      61 |      61 |      68 |     180 |  100000 |
| Time (wall clock) (μs)     |      59 |      60 |      60 |      60 |      61 |      67 |     188 |  100000 |


### Parse with ISO8601DateFormatter

| Metric                     |      p0 |     p25 |     p50 |     p75 |     p90 |     p99 |    p100 | Samples |
|----------------------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Malloc (total)             |     496 |     496 |     496 |     496 |     496 |     496 |     497 |  100000 |
| Memory (resident peak) (K) |    9748 |    9764 |    9764 |    9764 |    9764 |    9764 |    9764 |  100000 |
| Throughput (# / s) (K)     |      10 |      10 |      10 |      10 |      10 |       9 |       2 |  100000 |
| Time (total CPU) (μs)      |      94 |      95 |      95 |      95 |      95 |     103 |     293 |  100000 |
| Time (wall clock) (μs)     |      93 |      94 |      94 |      94 |      95 |     102 |     384 |  100000 |


### Parse with Parse3339 (DateComponents)

| Metric                     |      p0 |     p25 |     p50 |     p75 |     p90 |     p99 |    p100 | Samples |
|----------------------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Malloc (total)             |      64 |      64 |      64 |      64 |      64 |      64 |      67 |  100000 |
| Memory (resident peak) (M) |       9 |      41 |      73 |     105 |     124 |     136 |     137 |  100000 |
| Throughput (# / s) (K)     |      42 |      41 |      41 |      41 |      39 |      33 |      10 |  100000 |
| Time (total CPU) (μs)      |      24 |      24 |      24 |      24 |      26 |      30 |     100 |  100000 |
| Time (wall clock) (μs)     |      23 |      23 |      24 |      24 |      25 |      29 |      96 |  100000 |


### Parse with Parse3339 (Unix time)

| Metric                     |      p0 |     p25 |     p50 |     p75 |     p90 |     p99 |    p100 | Samples |
|----------------------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Malloc (total)             |       0 |       0 |       0 |       0 |       0 |       0 |       0 |  100000 |
| Memory (resident peak) (K) |    7798 |    7831 |    7831 |    7831 |    7831 |    7831 |    7831 |  100000 |
| Throughput (# / s) (K)     |     260 |     252 |     250 |     247 |     244 |     228 |      24 |  100000 |
| Time (total CPU) (ns)      |    4374 |    4503 |    4503 |    4543 |    4627 |    5043 |   41166 |  100000 |
| Time (wall clock) (ns)     |    3834 |    3959 |    4001 |    4041 |    4083 |    4375 |   40625 |  100000 |
