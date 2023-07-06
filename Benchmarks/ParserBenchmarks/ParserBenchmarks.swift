import Benchmark
import Foundation
import Parse3339

let benchmarks = {
    Benchmark("Parse with Parse3339", configuration: .init(maxDuration: .seconds(3))) { benchmark in
        let s = "2023-07-04T08:21:25+03:00"
        for _ in benchmark.scaledIterations {
            let parsed = parse(s)!
            let parsedDate = parsed.date!
            blackHole(parsedDate)
        }
    }

    Benchmark("Parse with ISO8601DateFormatter", configuration: .init(maxDuration: .seconds(3))) { benchmark in
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = .withInternetDateTime
        let s = "2023-07-04T08:21:25+03:00"

        for _ in benchmark.scaledIterations {
            let fmtDate = fmt.date(from: s)!
            blackHole(fmtDate)
        }
    }

    Benchmark("Parse with DateFormatter", configuration: .init(maxDuration: .seconds(3))) { benchmark in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let s = "2023-07-04T08:21:25+03:00"

        for _ in benchmark.scaledIterations {
            let fmtDate = dateFormatter.date(from: s)!
            blackHole(fmtDate)
        }
    }
}
