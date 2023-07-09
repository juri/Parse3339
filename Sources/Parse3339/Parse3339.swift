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

import Foundation

private let calendar = Calendar(identifier: .gregorian)
private let utc = TimeZone(secondsFromGMT: 0)

/// `Parts` contains the parsed fields from a time stamp.
public struct Parts {
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
    /// Number of subsecond fraction digits in the time stamp (0–10).
    public let secondFractionDigits: Int
    /// Time zone in minutes (-1439–1439).
    public let zone: Int

    /// The fractional second value in nanoseconds.
    public var nanosecond: Int {
        let multiplier = power10(self.secondFractionDigits)
        let nanoZeroes: Int = 9
        let leading = self.secondFraction * multiplier
        let missingDigits = nanoZeroes - self.secondFractionDigits - 1
        let nanoMultiplier = power10(missingDigits)
        return leading * nanoMultiplier
    }

    /// Time zone in seconds.
    public var zoneSeconds: Int {
        self.zone * 60
    }

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
            tm_zone: nil
        )
        let timet = timegm(&t)
        let offsetTimet = timet - self.zoneSeconds
        return Date(timeIntervalSince1970: TimeInterval(offsetTimet))
    }

    /// Parts as a `DateComponents` value.
    public var dateComponents: DateComponents {
        let d = DateComponents(
            calendar: calendar,
            timeZone: self.zoneSeconds == 0 ? utc : TimeZone(secondsFromGMT: self.zoneSeconds),
            year: self.year,
            month: self.month,
            day: self.day,
            hour: self.hour,
            minute: self.minute,
            second: self.second,
            nanosecond: self.nanosecond
        )
        return d
    }
}

extension Parts {
    fileprivate init(_ ps: ParseState) {
        self.init(
            year: ps.year,
            month: ps.month,
            day: ps.day,
            hour: ps.hour,
            minute: ps.minute,
            second: ps.second,
            secondFraction: ps.secondFraction,
            secondFractionDigits: ps.secondFractionDigits,
            zone: ps.zoneDirection.multiplier * (ps.zoneHour * 60 + ps.zoneMinute)
        )
    }
}

enum ZoneDirection {
    case plus
    case minus

    var multiplier: Int {
        switch self {
        case .plus: return 1
        case .minus: return -1
        }
    }
}

private enum Field {
    case year
    case month
    case day
    case hour
    case minute
    case second
    case secondFrac
    case zoneHour
    case zoneMinute
}

private func addDigit(_ num: Int, to target: Int) -> Int {
    target * 10 + num
}

enum Component: UInt8 {
    case n0 = 0x30
    case colon = 0x3A
    case dash = 0x2D
    case tee = 0x54
    case plus = 0x2B
    case period = 0x2E
    case zed = 0x5A
}

private struct ParseState {
    var field = Field.year
    var year = 0
    var month = 0
    var day = 0
    var hour = 0
    var minute = 0
    var second = 0
    var secondFraction = 0
    var secondFractionDigits = 0
    var zoneDirection = ZoneDirection.plus
    var zoneHour = 0
    var zoneMinute = 0
    var count = 0
}

/// Parse a `StringProtocol` into ``Parts``.
///
/// - SeeAlso: ``parse(_:)-9on3x``
@inlinable
public func parse(_ string: some StringProtocol) -> Parts? {
    parse(string.utf8)
}

/// Parse a sequence of `UInt8` values into ``Parts``.
///
/// - SeeAlso: ``parse(_:)-89jso``
public func parse(_ seq: some Sequence<UInt8>) -> Parts? {
    var state = ParseState()

    for element in seq {
        switch state.field {
        case .year:
            if state.count == 4 {
                if element == Component.dash.rawValue {
                    state.field = .month
                    state.count = 0
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                state.year = addDigit(num, to: state.year)
                state.count += 1
            } else {
                return nil
            }

        case .month:
            if state.count == 2 {
                if element == Component.dash.rawValue {
                    guard checkMonth(state.month) else {
                        return nil
                    }
                    state.field = .day
                    state.count = 0
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                state.month = addDigit(num, to: state.month)
                state.count += 1
            } else {
                return nil
            }

        case .day:
            if state.count == 2 {
                if element == Component.tee.rawValue {
                    guard checkDay(state.day) else {
                        return nil
                    }
                    state.field = .hour
                    state.count = 0
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                state.day = addDigit(num, to: state.day)
                state.count += 1
            } else {
                return nil
            }

        case .hour:
            if state.count == 2 {
                if element == Component.colon.rawValue {
                    state.field = .minute
                    state.count = 0
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                state.hour = addDigit(num, to: state.hour)
                guard checkHour(state.hour) else {
                    return nil
                }
                state.count += 1
            } else {
                return nil
            }

        case .minute:
            if state.count == 2 {
                if element == Component.colon.rawValue {
                    state.field = .second
                    state.count = 0
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                state.minute = addDigit(num, to: state.minute)
                guard checkMinute(state.minute) else {
                    return nil
                }
                state.count += 1
            } else {
                return nil
            }

        case .second:
            if state.count == 2 {
                if element == Component.period.rawValue {
                    state.field = .secondFrac
                    state.count = 0
                } else if element == Component.plus.rawValue {
                    state.field = .zoneHour
                    state.zoneDirection = .plus
                    state.count = 0
                } else if element == Component.dash.rawValue {
                    state.field = .zoneHour
                    state.zoneDirection = .minus
                    state.count = 0
                } else if element == Component.zed.rawValue {
                    return Parts(state)
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                state.second = addDigit(num, to: state.second)
                guard checkSecond(state.second) else {
                    return nil
                }
                state.count += 1
            } else {
                return nil
            }

        case .secondFrac:
            if let num = parseDigit(element) {
                if state.secondFractionDigits >= 10 {
                    return nil
                }
                state.secondFraction = addDigit(num, to: state.secondFraction)
                state.secondFractionDigits += 1
            } else if state.secondFractionDigits == 0 {
                return nil
            } else if element == Component.plus.rawValue {
                state.field = .zoneHour
            } else if element == Component.dash.rawValue {
                state.field = .zoneHour
                state.zoneDirection = .minus
            } else if element == Component.zed.rawValue {
                return Parts(state)
            } else {
                return nil
            }

        case .zoneHour:
            if state.count == 2 {
                if element == Component.colon.rawValue {
                    state.field = .zoneMinute
                    state.count = 0
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                state.zoneHour = addDigit(num, to: state.zoneHour)
                guard checkHour(state.zoneHour) else {
                    return nil
                }
                state.count += 1
            } else {
                return nil
            }

        case .zoneMinute:
            if state.count == 2 {
                return Parts(state)
            } else if let num = parseDigit(element) {
                state.zoneMinute = addDigit(num, to: state.zoneMinute)
                guard checkMinute(state.zoneMinute) else {
                    return nil
                }
                state.count += 1
            } else {
                return nil
            }
        }
    }

    if case .zoneMinute = state.field, state.count == 2 {
        return Parts(state)
    }
    return nil
}

func parseDigit(_ source: UInt8) -> Int? {
    let value = source &- Component.n0.rawValue
    return value < 10 ? Int(value) : nil
}

private func checkYear(_ year: Int) -> Bool {
    year >= 0 && year < 10000
}

private func checkMonth(_ month: Int) -> Bool {
    month > 0 && month < 13
}

private func checkDay(_ day: Int) -> Bool {
    day > 0 && day < 32
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
