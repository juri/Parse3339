import Benchmark
import Foundation
import Parse3339

var config: Benchmark.Configuration {
    Benchmark.Configuration(
        timeUnits: .nanoseconds,
        units: [
            .instructions: .kilo,
            .mallocBytesCount: .count,
        ],
        maxDuration: .seconds(30),
        maxIterations: 100_000,
    )
}

let benchmarks: @Sendable () -> Void = {
    // Vary both the values and the fraction/zone shapes. Keep construction out of
    // the measured loops, and consume all fields without converting to a Date.
    var samples = (0 ..< 8192).map { index in
        let year = 1900 + index % 200
        let month = String(format: "%02d", index % 12 + 1)
        let day = String(format: "%02d", index % 28 + 1)
        let hour = String(format: "%02d", index % 24)
        let minute = String(format: "%02d", index % 60)
        let fraction = ["", ".1", ".123", ".123456", ".123456789"][index % 5]
        let zone = ["Z", "+03:00", "-07:30", "-00:00"][index % 4]
        return "\(year)-\(month)-\(day)T\(hour):\(minute):25\(fraction)\(zone)"
    }
    // Deterministically shuffle so the branch predictor does not see a repeating
    // cycle of fraction lengths and zone formats. No RNG runs during measurement.
    var seed: UInt64 = 0x3339
    for index in stride(from: samples.count - 1, through: 1, by: -1) {
        seed ^= seed << 13
        seed ^= seed >> 7
        seed ^= seed << 17
        samples.swapAt(index, Int(seed % UInt64(index + 1)))
    }
    let strings = samples
    let bytes = samples.map { Array($0.utf8) }
    var parserConfig = config
    parserConfig.scalingFactor = .kilo

    Benchmark("Parse with Parse3339 (String only)", configuration: parserConfig) { benchmark in
        for index in benchmark.scaledIterations {
            blackHole(parse(strings[index % strings.count]))
        }
    }

    Benchmark("Parse with Parse3339 (Span only)", configuration: parserConfig) { benchmark in
        for index in benchmark.scaledIterations {
            bytes[index % bytes.count].withUnsafeBufferPointer { buffer in
                blackHole(parse(buffer.span))
            }
        }
    }

    #if WithFoundation
    Benchmark("Parse with Parse3339 (DateComponents)", configuration: config) { benchmark in
        let s = "2023-07-04T08:21:25+03:00"
        for _ in benchmark.scaledIterations {
            let parsed = parse(s)!
            let dateComponents = parsed.dateComponents
            let parsedDate = dateComponents!.date!
            blackHole(parsedDate)
        }
    }

    Benchmark("Parse with Parse3339 (Unix time)", configuration: config) { benchmark in
        let s = "2023-07-04T08:21:25+03:00"
        for _ in benchmark.scaledIterations {
            let parsed = parse(s)!
            let parsedDate = parsed.date
            blackHole(parsedDate)
        }
    }

    #endif

    Benchmark("Parse with ISO8601DateFormatter", configuration: config) { benchmark in
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = .withInternetDateTime
        let s = "2023-07-04T08:21:25+03:00"

        for _ in benchmark.scaledIterations {
            let fmtDate = fmt.date(from: s)!
            blackHole(fmtDate)
        }
    }

    Benchmark("Parse with DateFormatter", configuration: config) { benchmark in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let s = "2023-07-04T08:21:25+03:00"

        for _ in benchmark.scaledIterations {
            let fmtDate = dateFormatter.date(from: s)!
            blackHole(fmtDate)
        }
    }
}
