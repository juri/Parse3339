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

public struct Parts {
    public let year: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    public let second: Int
    public let secondFraction: Int
    public let secondFractionDigits: Int
    public let zone: Int

    public var nanosecond: Int {
        let multiplier = power10(self.secondFractionDigits)
        let nanoZeroes: Int = 9
        let leading = self.secondFraction * multiplier
        let missingDigits = nanoZeroes - self.secondFractionDigits - 1
        let nanoMultiplier = power10(missingDigits)
        return leading * nanoMultiplier
    }

    public var zoneSeconds: Int {
        self.zone * 60
    }

    public var dateComponents: DateComponents {
        let d = DateComponents(
            calendar: calendar,
            timeZone: TimeZone(secondsFromGMT: self.zoneSeconds),
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

    public var date: Date? {
        calendar.date(from: self.dateComponents)
    }
}

func power10(_ n: Int) -> Int {
    var out = 1
    for _ in 0 ..< n {
        out *= 10
    }
    return out
}

extension Parts {
    init(_ zm: State.ZoneMinute) {
        self.init(
            year: zm.year,
            month: zm.month,
            day: zm.day,
            hour: zm.hour,
            minute: zm.minute,
            second: zm.second,
            secondFraction: zm.fraction,
            secondFractionDigits: zm.fractionCount,
            zone: zm.zoneDirection.multiplier * (zm.zoneHour * 60 + zm.zoneMinute)
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

enum State {
    case year(year: Year, count: Int)
    case month(month: Month, count: Int)
    case day(day: Day, count: Int)
    case hour(hour: Hour, count: Int)
    case minute(minute: Minute, count: Int)
    case second(second: Second, count: Int)
    case secondFrac(frac: SecondFraction)
    case zoneHour(zoneHour: ZoneHour, count: Int)
    case zoneMinute(zoneMinute: ZoneMinute, count: Int)
}

extension State {
    struct Year {
        var year: Int
    }

    struct Month {
        let year: Int
        var month: Int
    }

    struct Day {
        let year: Int
        let month: Int
        var day: Int
    }

    struct Hour {
        let year: Int
        let month: Int
        let day: Int
        var hour: Int
    }

    struct Minute {
        let year: Int
        let month: Int
        let day: Int
        let hour: Int
        var minute: Int
    }

    struct Second {
        let year: Int
        let month: Int
        let day: Int
        let hour: Int
        let minute: Int
        var second: Int
    }

    struct SecondFraction {
        let year: Int
        let month: Int
        let day: Int
        let hour: Int
        let minute: Int
        let second: Int
        var fraction: Int
        var count: Int
    }

    struct ZoneHour {
        let year: Int
        let month: Int
        let day: Int
        let hour: Int
        let minute: Int
        let second: Int
        let fraction: Int
        let fractionCount: Int
        let zoneDirection: ZoneDirection
        var zoneHour: Int
    }

    struct ZoneMinute {
        let year: Int
        let month: Int
        let day: Int
        let hour: Int
        let minute: Int
        let second: Int
        let fraction: Int
        let fractionCount: Int
        let zoneDirection: ZoneDirection
        let zoneHour: Int
        var zoneMinute: Int
    }
}

private func addDigit(_ num: Int, to target: Int) -> Int {
    target * 10 + num
}

extension State.Year {
    mutating func add(_ num: Int) {
        self.year = addDigit(num, to: self.year)
    }
}

extension State.Month {
    init(_ year: State.Year) {
        self.init(year: year.year, month: 0)
    }

    mutating func add(_ num: Int) {
        self.month = addDigit(num, to: self.month)
    }
}

extension State.Day {
    init(_ month: State.Month) {
        self.init(year: month.year, month: month.month, day: 0)
    }

    mutating func add(_ num: Int) {
        self.day = addDigit(num, to: self.day)
    }
}

extension State.Hour {
    init(_ day: State.Day) {
        self.init(year: day.year, month: day.month, day: day.day, hour: 0)
    }

    mutating func add(_ num: Int) {
        self.hour = addDigit(num, to: self.hour)
    }
}

extension State.Minute {
    init(_ hour: State.Hour) {
        self.init(year: hour.year, month: hour.month, day: hour.day, hour: hour.hour, minute: 0)
    }

    mutating func add(_ num: Int) {
        self.minute = addDigit(num, to: self.minute)
    }
}

extension State.Second {
    init(_ minute: State.Minute) {
        self.init(
            year: minute.year, month: minute.month, day: minute.day, hour: minute.hour, minute: minute.minute, second: 0
        )
    }

    mutating func add(_ num: Int) {
        self.second = addDigit(num, to: self.second)
    }
}

extension State.SecondFraction {
    init(_ second: State.Second) {
        self.init(
            year: second.year,
            month: second.month,
            day: second.day,
            hour: second.hour,
            minute: second.minute,
            second: second.second,
            fraction: 0,
            count: 0
        )
    }

    mutating func add(_ num: Int) {
        self.fraction = addDigit(num, to: self.fraction)
        self.count += 1
    }
}

extension State.ZoneHour {
    init(_ frac: State.SecondFraction, direction: ZoneDirection) {
        self.init(
            year: frac.year,
            month: frac.month,
            day: frac.day,
            hour: frac.hour,
            minute: frac.minute,
            second: frac.second,
            fraction: frac.fraction,
            fractionCount: frac.count,
            zoneDirection: direction,
            zoneHour: 0
        )
    }
    
    mutating func add(_ num: Int) {
        self.zoneHour = addDigit(num, to: self.zoneHour)
    }
}

extension State.ZoneMinute {
    init(_ zh: State.ZoneHour) {
        self.init(
            year: zh.year,
            month: zh.month,
            day: zh.day,
            hour: zh.hour,
            minute: zh.minute,
            second: zh.second,
            fraction: zh.fraction,
            fractionCount: zh.fractionCount,
            zoneDirection: zh.zoneDirection,
            zoneHour: zh.zoneHour,
            zoneMinute: 0
        )
    }

    init(_ s: State.Second) {
        self.init(
            year: s.year,
            month: s.month,
            day: s.day,
            hour: s.hour,
            minute: s.minute,
            second: s.second,
            fraction: 0,
            fractionCount: 0,
            zoneDirection: .plus,
            zoneHour: 0,
            zoneMinute: 0
        )
    }

    init(_ f: State.SecondFraction) {
        self.init(
            year: f.year,
            month: f.month,
            day: f.day,
            hour: f.hour,
            minute: f.minute,
            second: f.second,
            fraction: f.fraction,
            fractionCount: f.count,
            zoneDirection: .plus,
            zoneHour: 0,
            zoneMinute: 0
        )
    }

    mutating func add(_ num: Int) {
        self.zoneMinute = addDigit(num, to: self.zoneMinute)
    }
}

enum Component: UInt8 {
    case n0 = 0x30
    case n1 = 0x31
    case n2 = 0x32
    case n3 = 0x33
    case n4 = 0x34
    case n5 = 0x35
    case n6 = 0x36
    case n7 = 0x37
    case n8 = 0x38
    case n9 = 0x39
    case colon = 0x3a
    case dash = 0x2d
    case tee = 0x54
    case plus = 0x2b
    case period = 0x2e
    case zed = 0x5a
}

@inlinable
public func parse(_ string: some StringProtocol) -> Parts? {
    parse(string.utf8)
}

public func parse<S>(_ seq: S) -> Parts? where S: Sequence, S.Element == UInt8 {
    var state = State.year(year: State.Year(year: 0), count: 0)

    for element in seq {
        switch state {
        case .year(year: var y, count: let c):
            if c == 4 {
                if element == Component.dash.rawValue {
                    state = .month(month: State.Month(y), count: 0)
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                y.add(num)
                state = .year(year: y, count: c + 1)
            } else {
                return nil
            }
            
        case .month(month: var m, count: let c):
            if c == 2 {
                if element == Component.dash.rawValue {
                    guard checkMonth(m.month) else {
                        return nil
                    }
                    state = .day(day: State.Day(m), count: 0)
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                m.add(num)
                state = .month(month: m, count: c + 1)
            } else {
                return nil
            }

        case .day(day: var d, count: let c):
            if c == 2 {
                if element == Component.tee.rawValue {
                    guard checkDay(d.day) else {
                        return nil
                    }
                    state = .hour(hour: State.Hour(d), count: 0)
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                d.add(num)
                state = .day(day: d, count: c + 1)
            } else {
                return nil
            }

        case .hour(hour: var h, count: let c):
            if c == 2 {
                if element == Component.colon.rawValue {
                    state = .minute(minute: State.Minute(h), count: 0)
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                h.add(num)
                guard checkHour(h.hour) else {
                    return nil
                }
                state = .hour(hour: h, count: c + 1)
            } else {
                return nil
            }

        case .minute(minute: var m, count: let c):
            if c == 2 {
                if element == Component.colon.rawValue {
                    state = .second(second: State.Second(m), count: 0)
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                m.add(num)
                guard checkMinute(m.minute) else {
                    return nil
                }
                state = .minute(minute: m, count: c + 1)
            } else {
                return nil
            }

        case .second(second: var s, count: let c):
            if c == 2 {
                if element == Component.period.rawValue {
                    state = .secondFrac(frac: State.SecondFraction(s))
                } else if element == Component.plus.rawValue {
                    state = .zoneHour(zoneHour: State.ZoneHour(State.SecondFraction(s), direction: .plus), count: 0)
                } else if element == Component.dash.rawValue {
                    state = .zoneHour(zoneHour: State.ZoneHour(State.SecondFraction(s), direction: .minus), count: 0)
                } else if element == Component.zed.rawValue {
                    let zm = State.ZoneMinute(s)
                    return Parts(zm)
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                s.add(num)
                guard checkSecond(s.second) else {
                    return nil
                }
                state = .second(second: s, count: c + 1)
            } else {
                return nil
            }

        case .secondFrac(frac: var f):
            if let num = parseDigit(element) {
                if f.count >= 10 {
                    return nil
                }
                f.add(num)
                state = .secondFrac(frac: f)
            } else if f.count == 0 {
                return nil
            } else if element == Component.plus.rawValue {
                state = .zoneHour(zoneHour: State.ZoneHour(f, direction: .plus), count: 0)
            } else if element == Component.dash.rawValue {
                state = .zoneHour(zoneHour: State.ZoneHour(f, direction: .minus), count: 0)
            } else if element == Component.zed.rawValue {
                let zm = State.ZoneMinute(f)
                return Parts(zm)
            } else {
                return nil
            }

        case .zoneHour(zoneHour: var zh, count: let c):
            if c == 2 {
                if element == Component.colon.rawValue {
                    state = .zoneMinute(zoneMinute: State.ZoneMinute(zh), count: 0)
                } else {
                    return nil
                }
            } else if let num = parseDigit(element) {
                zh.add(num)
                guard checkHour(zh.zoneHour) else {
                    return nil
                }
                state = .zoneHour(zoneHour: zh, count: c + 1)
            } else {
                return nil
            }

        case .zoneMinute(zoneMinute: var zm, count: let c):
            if c == 2 {
                return Parts(zm)
            } else if let num = parseDigit(element) {
                zm.add(num)
                guard checkMinute(zm.zoneMinute) else {
                    return nil
                }
                state = .zoneMinute(zoneMinute: zm, count: c + 1)
            } else {
                return nil
            }
        }
    }

    if case let .zoneMinute(zoneMinute: zm, count: c) = state, c == 2 {
        return Parts(zm)
    }
    return nil
}

func parseInt<S>(_ seq: S) -> (Int?, S.Element?) where S: Sequence, S.Element: BinaryInteger {
    var outInt: Int = 0
    for value in seq.prefix(1) {
        if let digit = parseDigit(value) {
            outInt = digit
            break
        }
        return (nil, value)
    }
    for value in seq {
        if let digit = parseDigit(value) {
            outInt *= 10
            outInt += digit
            break
        }
        return (outInt, value)
    }
    return (outInt, nil)
}

func parseDigit(_ source: some BinaryInteger) -> Int? {
    switch source as? UInt8 {
    case Component.n0.rawValue: return 0
    case Component.n1.rawValue: return 1
    case Component.n2.rawValue: return 2
    case Component.n3.rawValue: return 3
    case Component.n4.rawValue: return 4
    case Component.n5.rawValue: return 5
    case Component.n6.rawValue: return 6
    case Component.n7.rawValue: return 7
    case Component.n8.rawValue: return 8
    case Component.n9.rawValue: return 9
    default: return nil
    }
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
