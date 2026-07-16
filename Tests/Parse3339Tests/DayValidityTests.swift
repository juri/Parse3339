@testable import Parse3339
import Testing

@Suite struct DayValidityTests {
    @Test(
        arguments: [
            (2026, 1, 0),
            (2026, 1, 32),
            (2026, 2, 0),
            (2026, 2, 29),
            (2026, 3, 0),
            (2026, 3, 32),
            (2026, 4, 0),
            (2026, 4, 31),
            (2026, 5, 0),
            (2026, 5, 32),
            (2026, 6, 0),
            (2026, 6, 31),
            (2026, 7, 0),
            (2026, 7, 32),
            (2026, 8, 0),
            (2026, 8, 32),
            (2026, 9, 0),
            (2026, 9, 31),
            (2026, 10, 0),
            (2026, 10, 32),
            (2026, 11, 0),
            (2026, 11, 31),
            (2026, 12, 0),
            (2026, 12, 32),
        ],
    )
    func `invalid non-leap year day returns nil`(_ year: Int, _ month: Int, _ day: Int) {
        let s = "\(year)-\(month.formatted(.number.precision(.integerLength(2 ... 2))))-\(day.formatted(.number.precision(.integerLength(2 ... 2))))T01:02:03Z"
        #expect(parse(s) == nil)
    }

    @Test(
        arguments: [
            (2024, 1, 0),
            (2024, 1, 32),
            (2024, 2, 0),
            (2024, 2, 30),
            (2024, 3, 0),
            (2024, 3, 32),
            (2024, 4, 0),
            (2024, 4, 31),
            (2024, 5, 0),
            (2024, 5, 32),
            (2024, 6, 0),
            (2024, 6, 31),
            (2024, 7, 0),
            (2024, 7, 32),
            (2024, 8, 0),
            (2024, 8, 32),
            (2024, 9, 0),
            (2024, 9, 31),
            (2024, 10, 0),
            (2024, 10, 32),
            (2024, 11, 0),
            (2024, 11, 31),
            (2024, 12, 0),
            (2024, 12, 32),
        ],
    )

    func `invalid leap year day returns nil`(_ year: Int, _ month: Int, _ day: Int) {
        let s = "\(year)-\(month.formatted(.number.precision(.integerLength(2 ... 2))))-\(day.formatted(.number.precision(.integerLength(2 ... 2))))T01:02:03Z"
        #expect(parse(s) == nil)
    }
}
