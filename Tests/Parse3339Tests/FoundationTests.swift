#if WithFoundation

import Foundation
@testable import Parse3339
import Synchronization
import Testing

@Suite struct FoundationTests {
    @Test func fullZZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25.2Z"
        let parsed = try #require(parse(s))
        let unixTime = 1_688_458_885.2
        #expect(parsed.dateComponents!.date!.timeIntervalSince1970.isApproximatelyEqual(to: unixTime))
    }

    @Test func fullZZoneWithMillisecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295Z"
        let parsed = try #require(parse(s))
        let unixTime = 1_688_458_885.295
        #expect(parsed.dateComponents!.date!.timeIntervalSince1970.isApproximatelyEqual(to: unixTime))
    }

    @Test func fullZZoneWithMicrosecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295729Z"
        let parsed = try #require(parse(s))
        let unixTime = 1_688_458_885.295729
        #expect(parsed.dateComponents!.date!.timeIntervalSince1970.isApproximatelyEqual(to: unixTime))
    }

    @Test func fullZZoneToDateWithNanosecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295729572Z"
        let parsed = try #require(parse(s))
        let unixTime = 1_688_458_885.295729572
        #expect(parsed.date.timeIntervalSince1970.isApproximatelyEqual(to: unixTime))
    }

    @Test func fullZZoneWithNanosecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295729572Z"
        let parsed = try #require(parse(s))
        let unixTime = 1_688_458_885.295729572
        #expect(parsed.dateComponents!.date!.timeIntervalSince1970.isApproximatelyEqual(to: unixTime))
    }

    @Test func integralSecondsPlusZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25+03:00"
        let parsed = try #require(parse(s))
        let fmtDate = try #require(isoFormatter.date(from: s))
        let parsedDate = parsed.date
        #expect(fmtDate == parsedDate)
    }

    @Test func integralSecondsPlusZoneWithMinutesSuccessful() throws {
        let s = "2023-07-04T08:21:25+03:37"
        let parsed = try #require(parse(s))
        let fmtDate = try #require(isoFormatter.date(from: s))
        let parsedDate = parsed.date
        #expect(fmtDate == parsedDate)
    }

    @Test func integralSecondsMinusZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25-03:00"
        let parsed = try #require(parse(s))
        let fmtDate = try #require(isoFormatter.date(from: s))
        let parsedDate = parsed.date
        #expect(fmtDate == parsedDate)
    }

    @Test func integralSecondsMinusZoneWithMinutesSuccessful() throws {
        let s = "2023-07-04T08:21:25-03:14"
        let parsed = try #require(parse(s))
        let fmtDate = try #require(isoFormatter.date(from: s))
        let parsedDate = parsed.date
        #expect(fmtDate == parsedDate)
    }

    @Test func integralSecondsZZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25Z"
        let parsed = try #require(parse(s))
        let fmtDate = try #require(isoFormatter.date(from: s))
        let parsedDate = parsed.date
        #expect(fmtDate == parsedDate)
    }

    @Test func dateGen() throws {
        let isoFormatterUTC = ISO8601DateFormatter()
        let isoFormatterPlus = ISO8601DateFormatter()
        let isoFormatterMinus = ISO8601DateFormatter()
        isoFormatterUTC.formatOptions = .withInternetDateTime
        isoFormatterPlus.formatOptions = .withInternetDateTime
        isoFormatterMinus.formatOptions = .withInternetDateTime
        isoFormatterPlus.timeZone = TimeZone(secondsFromGMT: 6000)
        isoFormatterMinus.timeZone = TimeZone(secondsFromGMT: -18000)

        let formatters = [isoFormatterUTC, isoFormatterPlus, isoFormatterMinus]

        for timeInterval in stride(from: 0, to: 1_000_000_000, by: 100_000) {
            for formatter in formatters {
                let str = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(timeInterval)))
                let parsed = try #require(parse(str))
                let unixDate = parsed.date
                let dateComponents = parsed.dateComponents
                let calendarDate = try #require(dateComponents?.date)
                #expect(calendarDate == unixDate)
            }
        }
    }

    @Test func decodable() throws {
        struct Payload: Codable {
            let message: String
            let date: Date
        }

        let dateComponents = DateComponents(
            timeZone: TimeZone(identifier: "Europe/Helsinki"),
            year: 2023,
            month: 7,
            day: 11,
            hour: 8,
            minute: 49,
            second: 0,
        )
        let date = Calendar(identifier: .gregorian).date(from: dateComponents)!
        let payload = Payload(message: "hello world", date: date)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let json = try encoder.encode(payload)

        let didCallParse = Mutex<Bool>(false)
        @Sendable
        func wrappedParse(_ decoder: any Decoder) throws -> Date {
            didCallParse.withLock { $0 = true }
            return try parseFromDecoder(decoder)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(wrappedParse(_:))
        let decoded = try decoder.decode(Payload.self, from: json)

        #expect(didCallParse.withLock { $0 })
        #expect(decoded.message == "hello world")
        #expect(decoded.date == date)
    }

    @Test func `leap second is accepted and rolls over`() throws {
        let s = "2026-07-16T15:28:60.000Z"
        let p = try #require(parse(s))
        let dc = try #require(p.dateComponents)
        let dcd = try #require(dc.date)
        let pd = p.date
        #expect(dcd == pd)
        #expect(dcd.timeIntervalSinceReferenceDate == 805_908_540.0)
    }
}

private var isoFormatter: ISO8601DateFormatter {
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = .withInternetDateTime
    return fmt
}

#endif
