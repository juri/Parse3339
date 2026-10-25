/*
 date-fullyear   = 4DIGIT
 date-month      = 2DIGIT  ; 01-12
 date-mday       = 2DIGIT  ; 01-28, 01-29, 01-30, 01-31 based on
                           ; month/year
 time-hour       = 2DIGIT  ; 00-23
 time-minute     = 2DIGIT  ; 00-59
 time-second     = 2DIGIT  ; 00-58, 00-59, 00-60 based on leap second
                           ; rules
 time-secfrac    = "." 1*DIGIT
 time-numoffset  = ("+" / "-") time-hour ":" time-minute
 time-offset     = "Z" / time-numoffset

 partial-time    = time-hour ":" time-minute ":" time-second
                   [time-secfrac]
 full-date       = date-fullyear "-" date-month "-" date-mday
 full-time       = partial-time time-offset

 date-time       = full-date "T" full-time
 */

#if WithFoundation
import Foundation

private let calendar = Calendar(identifier: .gregorian)
private let utc = TimeZone(secondsFromGMT: 0)!
#endif

// MARK: Parts

/// `Parts` contains the parsed fields from a time stamp.
public struct Parts: Sendable {
    /// The year.
    public let year: Int
    /// The month (1–12).
    public let month: Int
    /// The day (1–31).
    public let day: Int
    /// The hour (0–23).
    public let hour: Int
    /// The minute (0–59).
    public let minute: Int
    /// The second (0–60).
    public let second: Int
    /// Subsecond fraction. `03.1234` as the second and fraction results in `1234` in this field. See ``secondFractionDigits`` for
    /// the number of digits after the period.
    public let secondFraction: Int
    /// Number of subsecond fraction digits in the time stamp (0–9).
    public let secondFractionDigits: Int
    /// Time zone in minutes (-1439–1439).
    ///
    /// If `zone` is nil, the input zone value was -00:00, indicating that the time is in UTC but offset to local time was unknown.
    ///
    /// - SeeAlso: Section 4.3 of RFC 3339, Unknown Local Offset Convention.
    public let zone: Int?
    /// The number of bytes consumed during parsing.
    public let consumedBytes: Int

    /// The fractional second value in nanoseconds.
    public var nanosecond: Int {
        let nanoZeroes: Int = 9
        return self.secondFraction * power10(nanoZeroes - self.secondFractionDigits)
    }

    /// Time zone in seconds.
    ///
    /// This property treats a nil ``zone`` the same as zero. See the documentation of `zone` for the meaning of nil.
    public var zoneSeconds: Int {
        (self.zone ?? 0) * 60
    }
}

#if WithFoundation

extension Parts {
    /// Parts as a `Date` value.
    public var date: Date {
        var t = tm(
            tm_sec: Int32(self.second),
            tm_min: Int32(self.minute),
            tm_hour: Int32(self.hour),
            tm_mday: Int32(self.day),
            tm_mon: Int32(self.month - 1),
            tm_year: Int32(self.year - 1900),
            tm_wday: 0,
            tm_yday: 0,
            tm_isdst: 0,
            tm_gmtoff: 0,
            tm_zone: nil,
        )
        let timet = timegm(&t)
        let offsetTimet = timet - self.zoneSeconds
        var timeInterval = TimeInterval(offsetTimet)
        timeInterval += TimeInterval(self.nanosecond) / 1_000_000_000
        return Date(timeIntervalSince1970: timeInterval)
    }

    /// Parts as a `DateComponents` value.
    ///
    /// This function constructs a `TimeZone`, whicih may not be able to represent the full range of time zones
    /// allowed by the parsed format. If `TimeZone` initialization fails, this property returns nil.
    public var dateComponents: DateComponents? {
        guard let tz: TimeZone = self.zoneSeconds == 0 ? utc : TimeZone(secondsFromGMT: self.zoneSeconds) else {
            return nil
        }
        let d = DateComponents(
            calendar: calendar,
            timeZone: tz,
            year: self.year,
            month: self.month,
            day: self.day,
            hour: self.hour,
            minute: self.minute,
            second: self.second,
            nanosecond: self.nanosecond,
        )
        return d
    }
}

#endif

// MARK: Parse functions

/// Parse a `String` into ``Parts``.
///
/// The string is allowed to contain trailing data, unless you specify `requireFullConsumption`. See
/// ``Parts/consumedBytes`` for the number of bytes consumed during parsing.
///
/// - Parameters:
///     - string: The string to parse.
///     - requireFullConsumption: If true and if the number of consumed bytes doesn't match the length of `string`, return nil.
///
/// - SeeAlso: Parse a `Substring` with ``parse(_:requireFullConsumption:)-(Substring,_)`` or a `Span<UInt8>` with ``parse(_:requireFullConsumption:)-(Span<UInt8>,_)``
@inlinable
public func parse(
    _ string: String,
    requireFullConsumption: Bool = false,
) -> Parts? {
    var string = string
    return string.withUTF8 { buffer in
        let span = buffer.span
        return parse(span, requireFullConsumption: requireFullConsumption)
    }
}

/// Parse a `Substring` into ``Parts``.
///
/// The substring is allowed to contain trailing data, unless you specify `requireFullConsumption`. See
/// ``Parts/consumedBytes`` for the number of bytes consumed during parsing.
///
/// - Parameters:
///     - substring: The substring to parse.
///     - requireFullConsumption: If true and if the number of consumed bytes doesn't match the length of `substring`, return nil.
///
/// - SeeAlso: Parse a `String` with ``parse(_:requireFullConsumption:)-(String,_)`` or a `Span<UInt8>` with ``parse(_:requireFullConsumption:)-(Span<UInt8>,_)``
@inlinable
public func parse(
    _ substring: Substring,
    requireFullConsumption: Bool = false,
) -> Parts? {
    var substring = substring
    return substring.withUTF8 { buffer in
        let span = buffer.span
        return parse(span, requireFullConsumption: requireFullConsumption)
    }
}

/// Parse the start of `Span` of `UInt8` values into ``Parts``.
///
/// The span is allowed to contain trailing data, unless you specify `requireFullConsumption`. See
/// ``Parts/consumedBytes`` for the number of bytes consumed during parsing.
///
/// `parse` doesn't perform leap second validation: it always accepts 60 as the seconds value, regardless
/// if date. If the leap second is invalid there, it automatically rolls over to zero seconds on the next minute
/// when converting the `Parts` value to a Date.
///
/// - Parameters:
///     - span: The span to parse.
///     - requireFullConsumption: If true and if the number of consumed bytes doesn't match the length of `span`, return nil.
///
/// - SeeAlso: Parse a `String` with ``parse(_:requireFullConsumption:)-(String,_)`` or a `Substring` with ``parse(_:requireFullConsumption:)-(Substring,_)``.
///            Both functions delegate the work to this one.
public func parse(
    _ span: Span<UInt8>,
    requireFullConsumption: Bool = false,
) -> Parts? {
    // The shortest supported time stamp is "0000-01-01T00:00:00Z".
    // These unaligned loads read bytes 0...7, 8...15, and 16...19, entirely
    // within the minimum length. Normalize byte order for the masks below.
    // Their windows are "YYYY-MM-", "DDTHH:MM", and ":SS?", low byte first.
    guard span.count >= 20 else { return nil }
    let date = span.bytes.unsafeLoadUnaligned(as: UInt64.self).littleEndian
    let time = span.bytes.unsafeLoadUnaligned(fromByteOffset: 8, as: UInt64.self).littleEndian
    let tail = span.bytes.unsafeLoadUnaligned(fromByteOffset: 16, as: UInt32.self).littleEndian
    guard date & 0xFF_00_00_FF_00_00_00_00 == 0x2D_00_00_2D_00_00_00_00,
          time & 0x00_00_FF_00_00_FF_00_00 == 0x00_00_3A_00_00_54_00_00,
          tail & 0xFF == 0x3A
    else { return nil }

    // XOR the expected separators to zero and ASCII digits to values 0...9.
    // Separators were checked above because zero is also a valid digit lane.
    let dateDigits = date ^ 0x2D_30_30_2D_30_30_30_30
    let timeDigits = time ^ 0x30_30_3A_30_30_54_30_30
    let secondDigits = UInt64((tail >> 8) & 0xFFFF) ^ 0x3030

    // In each byte, adding 0x76 sets bit 7 for values 10...127. OR with the
    // original value also rejects 128...255. Valid lanes cannot carry into
    // adjacent bytes; a carry from an invalid lane cannot hide its rejection.
    // Combine the independent words before testing their high bits once.
    let invalidDigits = ((dateDigits &+ 0x76_76_76_76_76_76_76_76) | dateDigits)
        | ((timeDigits &+ 0x76_76_76_76_76_76_76_76) | timeDigits)
        | ((secondDigits &+ 0x7676) | secondDigits)
    guard invalidDigits & 0x80_80_80_80_80_80_80_80 == 0 else { return nil }

    let year = decodeTwoDigits(dateDigits) * 100 + decodeTwoDigits(dateDigits >> 16)
    let month = decodeTwoDigits(dateDigits >> 40)
    let day = decodeTwoDigits(timeDigits)
    let hour = decodeTwoDigits(timeDigits >> 24)
    let minute = decodeTwoDigits(timeDigits >> 48)
    let second = decodeTwoDigits(secondDigits)
    guard checkMonth(month), checkHour(hour), checkMinute(minute), checkSecond(second) else { return nil }
    guard checkDay(year: year, month: month, day: day) else { return nil }

    var index = 19
    var fraction = 0
    var fractionDigits = 0
    if span[index] == Component.period.rawValue {
        index += 1
        while index < span.count, let digit = parseDigit(span[index]) {
            guard fractionDigits < 9 else { return nil }
            fraction = fraction * 10 + digit
            fractionDigits += 1
            index += 1
        }
        guard fractionDigits > 0, index < span.count else { return nil }
    }

    let zone: Int?
    let direction = span[index]
    if direction == Component.zed.rawValue {
        zone = 0
        index += 1
    } else {
        guard direction == Component.plus.rawValue || direction == Component.dash.rawValue,
              span.count - index >= 6,
              span[index + 3] == Component.colon.rawValue
        else {
            return nil
        }
        // The six-byte offset was checked above. Load its two digit pairs
        // without reading beyond it, then validate all four lanes together.
        let zoneHours = span.bytes.unsafeLoadUnaligned(fromByteOffset: index + 1, as: UInt16.self).littleEndian
        let zoneMinutes = span.bytes.unsafeLoadUnaligned(fromByteOffset: index + 4, as: UInt16.self).littleEndian
        let zoneDigits = (UInt32(zoneHours) | (UInt32(zoneMinutes) << 16)) ^ 0x30_30_30_30
        guard ((zoneDigits &+ 0x76_76_76_76) | zoneDigits) & 0x80_80_80_80 == 0 else { return nil }
        let zoneHour = decodeTwoDigits(UInt64(zoneDigits))
        let zoneMinute = decodeTwoDigits(UInt64(zoneDigits >> 16))
        guard checkHour(zoneHour), checkMinute(zoneMinute) else { return nil }
        let offset = zoneHour * 60 + zoneMinute
        zone = direction == Component.dash.rawValue ? (offset == 0 ? nil : -offset) : offset
        index += 6
    }

    guard !requireFullConsumption || index == span.count else { return nil }
    return Parts(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        secondFraction: fraction,
        secondFractionDigits: fractionDigits,
        zone: zone,
        consumedBytes: index,
    )
}

// MARK: JSONDecoder support

#if WithFoundation

/// Helper function for using Parse3339 with Codable types.
///
/// Use `parseFromDecoder(_:)` with a custom date decoding strategy. The mechanism depends on
/// the `TopLevelDecoder` implementation. With `JSONDecoder` you can use the `dateDecodingStrategy`
/// property with a `custom` value like this:
///
/// `parseFromDecoder(_:)` does not require full consumption of the string, matching Foundation's
/// `iso8601` parser which also allows trailing data after the time stamp.
///
/// ```swift
/// let decoder = JSONDecoder()
/// decoder.dateDecodingStrategy = .custom(Parse3339.parseFromDecoder(_:))
/// ```
///
/// `parseFromDecoder` first decodes a `String` and then parses the string. For formats other than JSON you may get
/// better performance by using an implementation that feeds bytes to ``parse(_:requireFullConsumption:)-(Span<UInt8>,_)``.
public func parseFromDecoder(_ decoder: some Decoder) throws -> Date {
    let container = try decoder.singleValueContainer()
    let str = try container.decode(String.self)
    guard let parsed = parse(str) else {
        throw DecodingError.typeMismatch(
            Date.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "The string '\(str)' could not be parsed as a date",
            ),
        )
    }
    return parsed.date
}

#endif

// MARK: - Private

// The two low bytes must already have been validated as decimal digit values.
private func decodeTwoDigits(_ digits: UInt64) -> Int {
    Int(digits & 0xFF) * 10 + Int((digits >> 8) & 0xFF)
}

private enum Component: UInt8 {
    case n0 = 0x30
    case colon = 0x3A
    case dash = 0x2D
    case tee = 0x54
    case plus = 0x2B
    case period = 0x2E
    case zed = 0x5A
}

func parseDigit(_ source: UInt8) -> Int? {
    let value = source &- Component.n0.rawValue
    return value < 10 ? Int(value) : nil
}

private func checkMonth(_ month: Int) -> Bool {
    month > 0 && month < 13
}

private func checkDay(year: Int, month: Int, day: Int) -> Bool {
    guard day > 0 && day < 32 else { return false }

    let isLeapYear = year.isMultiple(of: 400) || (year.isMultiple(of: 4) && !year.isMultiple(of: 100))

    let daysInMonth: Int
    switch month {
    case 2:
        daysInMonth = isLeapYear ? 29 : 28
    case 4, 6, 9, 11:
        daysInMonth = 30
    default:
        daysInMonth = 31
    }

    return day <= daysInMonth
}

private func checkHour(_ hour: Int) -> Bool {
    hour >= 0 && hour < 24
}

private func checkMinute(_ minute: Int) -> Bool {
    minute >= 0 && minute < 60
}

private func checkSecond(_ second: Int) -> Bool {
    second >= 0 && second < 61
}

private func power10(_ n: Int) -> Int {
    var out = 1
    for _ in 0 ..< n {
        out *= 10
    }
    return out
}
