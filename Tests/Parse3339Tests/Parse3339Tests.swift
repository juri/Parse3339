import Foundation
@testable import Parse3339
import XCTest

final class Parse3339Tests: XCTestCase {
    // MARK: Digits

    func testParseDigitSmallerThanNumbers() throws {
        XCTAssertNil(parseDigit(0x2F))
    }

    func testParseDigitZero() throws {
        XCTAssertEqual(parseDigit(0x30), 0)
    }

    func testParseDigitNine() throws {
        XCTAssertEqual(parseDigit(0x39), 9)
    }

    func testParseDigitLargerThanNumbers() throws {
        XCTAssertNil(parseDigit(0x3A))
    }

    // MARK: Full

    func testFullPlusZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25.2+03:00"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 2)
        XCTAssertEqual(parsed.secondFractionDigits, 1)
        XCTAssertEqual(parsed.zone, 180)
        XCTAssertEqual(parsed.nanosecond, 200_000_000)
    }

    func testFullPlusZoneWithMinutesSuccessful() throws {
        let s = "2023-07-04T08:21:25.2+03:37"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 2)
        XCTAssertEqual(parsed.secondFractionDigits, 1)
        XCTAssertEqual(parsed.zone, 217)
        XCTAssertEqual(parsed.nanosecond, 200_000_000)
    }

    func testFullMinusZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25.2-03:00"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 2)
        XCTAssertEqual(parsed.secondFractionDigits, 1)
        XCTAssertEqual(parsed.zone, -180)
        XCTAssertEqual(parsed.nanosecond, 200_000_000)
    }

    func testFullMinusZoneWithMinutesSuccessful() throws {
        let s = "2023-07-04T08:21:25.2-03:14"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 2)
        XCTAssertEqual(parsed.secondFractionDigits, 1)
        XCTAssertEqual(parsed.zone, -194)
        XCTAssertEqual(parsed.nanosecond, 200_000_000)
    }

    func testFullZZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25.2Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 2)
        XCTAssertEqual(parsed.secondFractionDigits, 1)
        XCTAssertEqual(parsed.zone, 0)
        XCTAssertEqual(parsed.nanosecond, 200_000_000)

        let unixTime = 1_688_458_885.2
        XCTAssertEqual(parsed.dateComponents.date!.timeIntervalSince1970, unixTime, accuracy: 0.1)
    }

    func testFullZZoneWithMillisecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 295)
        XCTAssertEqual(parsed.secondFractionDigits, 3)
        XCTAssertEqual(parsed.zone, 0)
        XCTAssertEqual(parsed.nanosecond, 295_000_000)

        let unixTime = 1_688_458_885.295
        XCTAssertEqual(parsed.dateComponents.date!.timeIntervalSince1970, unixTime, accuracy: 0.001)
    }

    func testFullZZoneWithMicrosecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295729Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 295_729)
        XCTAssertEqual(parsed.secondFractionDigits, 6)
        XCTAssertEqual(parsed.zone, 0)
        XCTAssertEqual(parsed.nanosecond, 295_729_000)

        let unixTime = 1_688_458_885.295729
        XCTAssertEqual(parsed.dateComponents.date!.timeIntervalSince1970, unixTime, accuracy: 0.000001)
    }

    func testFullZZoneWithNanosecondsSuccessful() throws {
        let s = "2023-07-04T08:21:25.295729572Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 295_729_572)
        XCTAssertEqual(parsed.secondFractionDigits, 9)
        XCTAssertEqual(parsed.zone, 0)
        XCTAssertEqual(parsed.nanosecond, 295_729_572)

        let unixTime = 1_688_458_885.295729572
        XCTAssertEqual(parsed.dateComponents.date!.timeIntervalSince1970, unixTime, accuracy: 0.000000001)
    }

    // MARK: Without fractions

    func testIntegralSecondsPlusZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25+03:00"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 180)
        XCTAssertEqual(parsed.nanosecond, 0)

        let fmtDate = try XCTUnwrap(isoFormatter.date(from: s))
        let parsedDate = try XCTUnwrap(parsed.date)
        XCTAssertEqual(fmtDate, parsedDate)
    }

    func testIntegralSecondsPlusZoneWithMinutesSuccessful() throws {
        let s = "2023-07-04T08:21:25+03:37"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 217)

        let fmtDate = try XCTUnwrap(isoFormatter.date(from: s))
        let parsedDate = try XCTUnwrap(parsed.date)
        XCTAssertEqual(fmtDate, parsedDate)
    }

    func testIntegralSecondsMinusZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25-03:00"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, -180)

        let fmtDate = try XCTUnwrap(isoFormatter.date(from: s))
        let parsedDate = try XCTUnwrap(parsed.date)
        XCTAssertEqual(fmtDate, parsedDate)
    }

    func testIntegralSecondsMinusZoneWithMinutesSuccessful() throws {
        let s = "2023-07-04T08:21:25-03:14"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, -194)

        let fmtDate = try XCTUnwrap(isoFormatter.date(from: s))
        let parsedDate = try XCTUnwrap(parsed.date)
        XCTAssertEqual(fmtDate, parsedDate)
    }

    func testIntegralSecondsZZoneSuccessful() throws {
        let s = "2023-07-04T08:21:25Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 7)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)

        let fmtDate = try XCTUnwrap(isoFormatter.date(from: s))
        let parsedDate = try XCTUnwrap(parsed.date)
        XCTAssertEqual(fmtDate, parsedDate)
    }

    // MARK: Truncated

    func testTruncated() throws {
        let s = "2023-07-04T08:21:25Z"
        for i in 1 ... s.count {
            let truncated = s.dropLast(i)
            XCTAssertNil(parse(truncated), "Expected nil when parsing '\(truncated)'")
        }
    }

    // MARK: Field limits

    func testZeroMonth() throws {
        let s = "2023-00-04T08:21:25Z"
        XCTAssertNil(parse(s))
    }

    func testJanuary() throws {
        let s = "2023-01-04T08:21:25Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 1)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testDecemberMonth() throws {
        let s = "2023-12-04T08:21:25Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 4)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testLargeMonth() throws {
        let s = "2023-13-04T08:21:25Z"
        XCTAssertNil(parse(s))
    }

    func testZeroDay() throws {
        let s = "2023-12-00T08:21:25Z"
        XCTAssertNil(parse(s))
    }

    func testFirstDay() throws {
        let s = "2023-12-01T08:21:25Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 1)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testThirtyFirstDay() throws {
        let s = "2023-12-31T08:21:25Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testLargeDay() throws {
        let s = "2023-12-32T08:21:25Z"
        XCTAssertNil(parse(s))
    }

    func testHour0() throws {
        let s = "2023-12-31T00:21:25Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 0)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testHour23() throws {
        let s = "2023-12-31T23:21:25Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 23)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testHour24() throws {
        let s = "2023-12-31T24:21:25Z"
        XCTAssertNil(parse(s))
    }

    func testMinute0() throws {
        let s = "2023-12-31T09:00:25Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 9)
        XCTAssertEqual(parsed.minute, 0)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testMinute1() throws {
        let s = "2023-12-31T09:01:25Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 9)
        XCTAssertEqual(parsed.minute, 1)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testMinute59() throws {
        let s = "2023-12-31T09:01:25Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 9)
        XCTAssertEqual(parsed.minute, 1)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testMinute60() throws {
        let s = "2023-12-31T09:60:25Z"
        XCTAssertNil(parse(s))
    }

    func testSecond0() throws {
        let s = "2023-12-31T09:00:00Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 9)
        XCTAssertEqual(parsed.minute, 0)
        XCTAssertEqual(parsed.second, 0)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testSecond1() throws {
        let s = "2023-12-31T09:01:01Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 9)
        XCTAssertEqual(parsed.minute, 1)
        XCTAssertEqual(parsed.second, 1)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testSecond60() throws {
        let s = "2023-12-31T09:01:60Z"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 9)
        XCTAssertEqual(parsed.minute, 1)
        XCTAssertEqual(parsed.second, 60)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 0)
    }

    func testSecond61() throws {
        let s = "2023-12-31T09:01:61Z"
        XCTAssertNil(parse(s))
    }

    func testZoneHour0() throws {
        let s = "2023-12-31T00:21:25+00:12"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 0)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 12)
    }

    func testZoneHour23() throws {
        let s = "2023-12-31T23:21:25+23:03"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 23)
        XCTAssertEqual(parsed.minute, 21)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 1383)
    }

    func testHourZone24() throws {
        let s = "2023-12-31T12:21:25+24:00"
        XCTAssertNil(parse(s))
    }

    func testZoneMinute0() throws {
        let s = "2023-12-31T09:00:25-13:00"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 9)
        XCTAssertEqual(parsed.minute, 0)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, -780)
    }

    func testZoneMinute1() throws {
        let s = "2023-12-31T09:01:24+02:01"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 9)
        XCTAssertEqual(parsed.minute, 1)
        XCTAssertEqual(parsed.second, 24)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, 121)
    }

    func testZoneMinute59() throws {
        let s = "2023-12-31T09:01:25-15:59"
        let parsed = try XCTUnwrap(parse(s))

        XCTAssertEqual(parsed.year, 2023)
        XCTAssertEqual(parsed.month, 12)
        XCTAssertEqual(parsed.day, 31)
        XCTAssertEqual(parsed.hour, 9)
        XCTAssertEqual(parsed.minute, 1)
        XCTAssertEqual(parsed.second, 25)
        XCTAssertEqual(parsed.secondFraction, 0)
        XCTAssertEqual(parsed.secondFractionDigits, 0)
        XCTAssertEqual(parsed.zone, -959)
    }

    func testZoneMinute60() throws {
        let s = "2023-12-31T09:12:25+08:60"
        XCTAssertNil(parse(s))
    }

    // MARK: Short fields

    func testShortYear() throws {
        let s = "202-12-31T09:01:00Z"
        XCTAssertNil(parse(s))
    }

    func testShortMonth() throws {
        let s = "2023-1-31T09:01:00Z"
        XCTAssertNil(parse(s))
    }

    func testShortDay() throws {
        let s = "2023-01-3T09:01:00Z"
        XCTAssertNil(parse(s))
    }

    func testShortHour() throws {
        let s = "2023-01-03T9:01:00Z"
        XCTAssertNil(parse(s))
    }

    func testShortMinute() throws {
        let s = "2023-01-03T09:1:00Z"
        XCTAssertNil(parse(s))
    }

    func testShortSecond() throws {
        let s = "2023-01-03T09:01:0Z"
        XCTAssertNil(parse(s))
    }

    func testMissingSecondFraction() throws {
        let s = "2023-01-03T09:01:00.Z"
        XCTAssertNil(parse(s))
    }

    func testShortZoneHour() throws {
        let s = "2023-01-03T09:01:01+0:00"
        XCTAssertNil(parse(s))
    }

    // MARK: Long fields

    func testLongYear() throws {
        let s = "20200-12-31T09:01:00Z"
        XCTAssertNil(parse(s))
    }

    func testLongMonth() throws {
        let s = "2023-100-31T09:01:00Z"
        XCTAssertNil(parse(s))
    }

    func testLongDay() throws {
        let s = "2023-01-301T09:01:00Z"
        XCTAssertNil(parse(s))
    }

    func testLongHour() throws {
        let s = "2023-01-03T091:01:00Z"
        XCTAssertNil(parse(s))
    }

    func testLongMinute() throws {
        let s = "2023-01-03T09:011:00Z"
        XCTAssertNil(parse(s))
    }

    func testLongSecond() throws {
        let s = "2023-01-03T09:01:001Z"
        XCTAssertNil(parse(s))
    }

    func testLongFraction() throws {
        let s = "2023-01-03T09:01:00.12345678901Z"
        XCTAssertNil(parse(s))
    }

    func testLongZoneHour() throws {
        let s = "2023-01-03T09:01:01+001:00"
        XCTAssertNil(parse(s))
    }

    // MARK: Date generator

    func testDateGen() throws {
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
                let parsed = try XCTUnwrap(parse(str))
                let unixDate = parsed.date
                let dateComponents = parsed.dateComponents
                let calendarDate = try XCTUnwrap(dateComponents.date)
                XCTAssertEqual(calendarDate, unixDate)
            }
        }
    }

    // MARK: Decodable

    func testDecodable() throws {
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
            second: 0
        )
        let date = Calendar(identifier: .gregorian).date(from: dateComponents)!
        let payload = Payload(message: "hello world", date: date)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let json = try encoder.encode(payload)

        var didCallParse = false
        func wrappedParse(_ decoder: any Decoder) throws -> Date {
            didCallParse = true
            return try parseFromDecoder(decoder)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(wrappedParse(_:))
        let decoded = try decoder.decode(Payload.self, from: json)

        XCTAssertTrue(didCallParse)
        XCTAssertEqual(decoded.message, "hello world")
        XCTAssertEqual(decoded.date, date)
    }
}

let isoFormatter: ISO8601DateFormatter = {
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = .withInternetDateTime
    return fmt
}()
