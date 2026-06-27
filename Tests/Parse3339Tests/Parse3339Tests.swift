import Foundation
import Numerics
@testable import Parse3339
import Synchronization
import Testing

@Suite struct Parse3339Tests {
    // MARK: Digits

    @Test func parseDigitSmallerThanNumbers() throws {
        #expect(parseDigit(0x2F) == nil)
    }

    @Test func parseDigitZero() throws {
        #expect(parseDigit(0x30) == 0)
    }

    @Test func parseDigitNine() throws {
        #expect(parseDigit(0x39) == 9)
    }

    @Test func parseDigitLargerThanNumbers() throws {
        #expect(parseDigit(0x3A) == nil)
    }

    // MARK: Full

    @Test func fullPlusZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25.2+03:00"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 2)
        #expect(parsed.secondFractionDigits == 1)
        #expect(parsed.zone == 180)
        #expect(parsed.nanosecond == 200_000_000)
    }

    @Test func fullPlusZoneWithMinutesSuccessful() throws {
        let s = "2023-07-04T08:21:25.2+03:37"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 2)
        #expect(parsed.secondFractionDigits == 1)
        #expect(parsed.zone == 217)
        #expect(parsed.nanosecond == 200_000_000)
    }

    @Test func fullMinusZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25.2-03:00"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 2)
        #expect(parsed.secondFractionDigits == 1)
        #expect(parsed.zone == -180)
        #expect(parsed.nanosecond == 200_000_000)
    }

    @Test func fullMinusZoneWithMinutesSuccessful() throws {
        let s = "2023-07-04T08:21:25.2-03:14"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 2)
        #expect(parsed.secondFractionDigits == 1)
        #expect(parsed.zone == -194)
        #expect(parsed.nanosecond == 200_000_000)
    }

    @Test func fullZZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25.2Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 2)
        #expect(parsed.secondFractionDigits == 1)
        #expect(parsed.zone == 0)
        #expect(parsed.nanosecond == 200_000_000)

        let unixTime = 1_688_458_885.2
        #expect(parsed.dateComponents.date!.timeIntervalSince1970.isApproximatelyEqual(to: unixTime))
    }

    @Test func fullZZoneWithMillisecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 295)
        #expect(parsed.secondFractionDigits == 3)
        #expect(parsed.zone == 0)
        #expect(parsed.nanosecond == 295_000_000)

        let unixTime = 1_688_458_885.295
        #expect(parsed.dateComponents.date!.timeIntervalSince1970.isApproximatelyEqual(to: unixTime))
    }

    @Test func fullZZoneWithMicrosecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295729Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 295_729)
        #expect(parsed.secondFractionDigits == 6)
        #expect(parsed.zone == 0)
        #expect(parsed.nanosecond == 295_729_000)

        let unixTime = 1_688_458_885.295729
        #expect(parsed.dateComponents.date!.timeIntervalSince1970.isApproximatelyEqual(to: unixTime))
    }

    @Test func fullZZoneToDateWithNanosecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295729572Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 295_729_572)
        #expect(parsed.secondFractionDigits == 9)
        #expect(parsed.zone == 0)
        #expect(parsed.nanosecond == 295_729_572)

        let unixTime = 1_688_458_885.295729572
        #expect(parsed.date.timeIntervalSince1970.isApproximatelyEqual(to: unixTime))
    }

    @Test func fullZZoneWithNanosecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295729572Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 295_729_572)
        #expect(parsed.secondFractionDigits == 9)
        #expect(parsed.zone == 0)
        #expect(parsed.nanosecond == 295_729_572)

        let unixTime = 1_688_458_885.295729572
        #expect(parsed.dateComponents.date!.timeIntervalSince1970.isApproximatelyEqual(to: unixTime))
    }

    // MARK: Without fractions

    @Test func integralSecondsPlusZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25+03:00"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 180)
        #expect(parsed.nanosecond == 0)

        let fmtDate = try #require(isoFormatter.date(from: s))
        let parsedDate = parsed.date
        #expect(fmtDate == parsedDate)
    }

    @Test func integralSecondsPlusZoneWithMinutesSuccessful() throws {
        let s = "2023-07-04T08:21:25+03:37"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 217)

        let fmtDate = try #require(isoFormatter.date(from: s))
        let parsedDate = parsed.date
        #expect(fmtDate == parsedDate)
    }

    @Test func integralSecondsMinusZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25-03:00"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == -180)

        let fmtDate = try #require(isoFormatter.date(from: s))
        let parsedDate = parsed.date
        #expect(fmtDate == parsedDate)
    }

    @Test func integralSecondsMinusZoneWithMinutesSuccessful() throws {
        let s = "2023-07-04T08:21:25-03:14"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == -194)

        let fmtDate = try #require(isoFormatter.date(from: s))
        let parsedDate = parsed.date
        #expect(fmtDate == parsedDate)
    }

    @Test func integralSecondsZZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 7)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)

        let fmtDate = try #require(isoFormatter.date(from: s))
        let parsedDate = parsed.date
        #expect(fmtDate == parsedDate)
    }

    // MARK: Truncated

    @Test func truncated() throws {
        let s = "2023-07-04T08:21:25Z"
        for i in 1 ... s.count {
            let truncated = s.dropLast(i)
            #expect(parse(truncated) == nil, "Expected nil when parsing '\(truncated)'")
        }
    }

    // MARK: Field limits

    @Test func zeroMonth() throws {
        let s = "2023-00-04T08:21:25Z"
        #expect(parse(s) == nil)
    }

    @Test func january() throws {
        let s = "2023-01-04T08:21:25Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 1)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func decemberMonth() throws {
        let s = "2023-12-04T08:21:25Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 4)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func largeMonth() throws {
        let s = "2023-13-04T08:21:25Z"
        #expect(parse(s) == nil)
    }

    @Test func zeroDay() throws {
        let s = "2023-12-00T08:21:25Z"
        #expect(parse(s) == nil)
    }

    @Test func firstDay() throws {
        let s = "2023-12-01T08:21:25Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 1)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func thirtyFirstDay() throws {
        let s = "2023-12-31T08:21:25Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 8)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func largeDay() throws {
        let s = "2023-12-32T08:21:25Z"
        #expect(parse(s) == nil)
    }

    @Test func hour0() throws {
        let s = "2023-12-31T00:21:25Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 0)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func hour23() throws {
        let s = "2023-12-31T23:21:25Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 23)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func hour24() throws {
        let s = "2023-12-31T24:21:25Z"
        #expect(parse(s) == nil)
    }

    @Test func minute0() throws {
        let s = "2023-12-31T09:00:25Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 9)
        #expect(parsed.minute == 0)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func minute1() throws {
        let s = "2023-12-31T09:01:25Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 9)
        #expect(parsed.minute == 1)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func minute59() throws {
        let s = "2023-12-31T09:01:25Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 9)
        #expect(parsed.minute == 1)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func minute60() throws {
        let s = "2023-12-31T09:60:25Z"
        #expect(parse(s) == nil)
    }

    @Test func second0() throws {
        let s = "2023-12-31T09:00:00Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 9)
        #expect(parsed.minute == 0)
        #expect(parsed.second == 0)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func second1() throws {
        let s = "2023-12-31T09:01:01Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 9)
        #expect(parsed.minute == 1)
        #expect(parsed.second == 1)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func second60() throws {
        let s = "2023-12-31T09:01:60Z"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 9)
        #expect(parsed.minute == 1)
        #expect(parsed.second == 60)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 0)
    }

    @Test func second61() throws {
        let s = "2023-12-31T09:01:61Z"
        #expect(parse(s) == nil)
    }

    @Test func zoneHour0() throws {
        let s = "2023-12-31T00:21:25+00:12"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 0)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 12)
    }

    @Test func zoneHour23() throws {
        let s = "2023-12-31T23:21:25+23:03"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 23)
        #expect(parsed.minute == 21)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 1383)
    }

    @Test func hourZone24() throws {
        let s = "2023-12-31T12:21:25+24:00"
        #expect(parse(s) == nil)
    }

    @Test func zoneMinute0() throws {
        let s = "2023-12-31T09:00:25-13:00"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 9)
        #expect(parsed.minute == 0)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == -780)
    }

    @Test func zoneMinute1() throws {
        let s = "2023-12-31T09:01:24+02:01"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 9)
        #expect(parsed.minute == 1)
        #expect(parsed.second == 24)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == 121)
    }

    @Test func zoneMinute59() throws {
        let s = "2023-12-31T09:01:25-15:59"
        let parsed = try #require(parse(s))

        #expect(parsed.year == 2023)
        #expect(parsed.month == 12)
        #expect(parsed.day == 31)
        #expect(parsed.hour == 9)
        #expect(parsed.minute == 1)
        #expect(parsed.second == 25)
        #expect(parsed.secondFraction == 0)
        #expect(parsed.secondFractionDigits == 0)
        #expect(parsed.zone == -959)
    }

    @Test func zoneMinute60() throws {
        let s = "2023-12-31T09:12:25+08:60"
        #expect(parse(s) == nil)
    }

    // MARK: Short fields

    @Test func shortYear() throws {
        let s = "202-12-31T09:01:00Z"
        #expect(parse(s) == nil)
    }

    @Test func shortMonth() throws {
        let s = "2023-1-31T09:01:00Z"
        #expect(parse(s) == nil)
    }

    @Test func shortDay() throws {
        let s = "2023-01-3T09:01:00Z"
        #expect(parse(s) == nil)
    }

    @Test func shortHour() throws {
        let s = "2023-01-03T9:01:00Z"
        #expect(parse(s) == nil)
    }

    @Test func shortMinute() throws {
        let s = "2023-01-03T09:1:00Z"
        #expect(parse(s) == nil)
    }

    @Test func shortSecond() throws {
        let s = "2023-01-03T09:01:0Z"
        #expect(parse(s) == nil)
    }

    @Test func missingSecondFraction() throws {
        let s = "2023-01-03T09:01:00.Z"
        #expect(parse(s) == nil)
    }

    @Test func shortZoneHour() throws {
        let s = "2023-01-03T09:01:01+0:00"
        #expect(parse(s) == nil)
    }

    // MARK: Long fields

    @Test func longYear() throws {
        let s = "20200-12-31T09:01:00Z"
        #expect(parse(s) == nil)
    }

    @Test func longMonth() throws {
        let s = "2023-100-31T09:01:00Z"
        #expect(parse(s) == nil)
    }

    @Test func longDay() throws {
        let s = "2023-01-301T09:01:00Z"
        #expect(parse(s) == nil)
    }

    @Test func longHour() throws {
        let s = "2023-01-03T091:01:00Z"
        #expect(parse(s) == nil)
    }

    @Test func longMinute() throws {
        let s = "2023-01-03T09:011:00Z"
        #expect(parse(s) == nil)
    }

    @Test func longSecond() throws {
        let s = "2023-01-03T09:01:001Z"
        #expect(parse(s) == nil)
    }

    @Test func longFraction() throws {
        let s = "2023-01-03T09:01:00.12345678901Z"
        #expect(parse(s) == nil)
    }

    @Test func longZoneHour() throws {
        let s = "2023-01-03T09:01:01+001:00"
        #expect(parse(s) == nil)
    }

    // MARK: Date generator

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
                let calendarDate = try #require(dateComponents.date)
                #expect(calendarDate == unixDate)
            }
        }
    }

    // MARK: Decodable

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
}

var isoFormatter: ISO8601DateFormatter {
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = .withInternetDateTime
    return fmt
}
