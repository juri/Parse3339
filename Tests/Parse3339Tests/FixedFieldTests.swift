@testable import Parse3339
import Testing

@Suite struct FixedFieldTests {
    @Test(arguments: [
        "0000-01-01T00:00:00Z",
        "2024-02-29T23:59:60.1Z",
        "9999-12-31T23:59:59.123456789+23:59",
        "2023-07-04T08:21:25-00:00",
        "2023-07-04T08:21:25.123456789-00:00",
    ])
    func truncated(_ timestamp: String) {
        let bytes = Array(timestamp.utf8)
        for count in 0 ..< bytes.count {
            #expect(bytes.prefix(count).withUnsafeBufferPointer { parse($0.span) } == nil)
        }
        #expect(bytes.withUnsafeBufferPointer { parse($0.span, requireFullConsumption: true) } != nil)
    }

    @Test func nonDigits() {
        let bytes = Array("2024-02-29T23:59:60.123456789+23:59".utf8)
        for index in bytes.indices where bytes[index] >= 0x30 && bytes[index] <= 0x39 {
            for value in UInt8.min ... UInt8.max where value < 0x30 || value > 0x39 {
                var invalid = bytes
                invalid[index] = value
                #expect(invalid.withUnsafeBufferPointer { parse($0.span, requireFullConsumption: true) } == nil)
            }
        }
    }

    @Test func separators() {
        let bytes = Array("2024-02-29T23:59:60.123456789+23:59".utf8)
        for index in [4, 7, 10, 13, 16, 32] {
            for value in UInt8.min ... UInt8.max where value != bytes[index] {
                var invalid = bytes
                invalid[index] = value
                #expect(invalid.withUnsafeBufferPointer { parse($0.span) } == nil)
            }
        }
    }

    // Exhaustive byte pairs exercise carries between SWAR lanes, including
    // cases where both bytes are invalid. The other fields stay valid.
    @Test(arguments: [
        (0, 0 ... 99), (2, 0 ... 99), (5, 1 ... 12), (8, 1 ... 31),
        (11, 0 ... 23), (14, 0 ... 59), (17, 0 ... 60),
        (20, 0 ... 23), (23, 0 ... 59),
    ])
    func bytePairs(_ index: Int, _ validValues: ClosedRange<Int>) {
        var bytes = Array("2000-01-01T00:00:00+00:00".utf8)
        for first in UInt8.min ... UInt8.max {
            for second in UInt8.min ... UInt8.max {
                bytes[index] = first
                bytes[index + 1] = second
                let digits = first >= 0x30 && first <= 0x39 && second >= 0x30 && second <= 0x39
                let value = (Int(first) - 0x30) * 10 + Int(second) - 0x30
                let expected = digits && validValues.contains(value)
                let parsed = bytes.withUnsafeBufferPointer { parse($0.span, requireFullConsumption: true) }
                #expect((parsed != nil) == expected)
            }
        }
    }

    @Test(arguments: [
        "0000-01-01T00:00:00Z",
        "9999-12-31T23:59:60+23:59",
        "2024-02-29T12:34:56.123456789-00:00",
    ])
    func unalignedInput(_ timestamp: String) throws {
        for offset in 0 ..< 8 {
            let bytes = Array(repeating: UInt8(0xFF), count: offset) + Array(timestamp.utf8)
            let parts = try #require(bytes.withUnsafeBufferPointer { buffer in
                parse(buffer.span.extracting(offset...), requireFullConsumption: true)
            })
            #expect(parts.consumedBytes == timestamp.utf8.count)
        }
    }

    @Test func slicedInputsAndUnicodeTrailingData() throws {
        let timestamp = "2024-02-29T23:59:60.123456789-00:00"
        let surrounded = "prefix\(timestamp)🌍"
        let substring = surrounded.dropFirst(6)
        let bytes = Array(surrounded.utf8).dropFirst(6)
        let results = [parse(String(substring)), parse(substring), bytes.withUnsafeBufferPointer { parse($0.span) }]
        for result in results {
            let parts = try #require(result)
            #expect(parts.year == 2024)
            #expect(parts.month == 2)
            #expect(parts.day == 29)
            #expect(parts.hour == 23)
            #expect(parts.minute == 59)
            #expect(parts.second == 60)
            #expect(parts.secondFraction == 123_456_789)
            #expect(parts.secondFractionDigits == 9)
            #expect(parts.zone == nil)
            #expect(parts.consumedBytes == timestamp.utf8.count)
        }
        #expect(parse(String(substring), requireFullConsumption: true) == nil)
        #expect(parse(substring, requireFullConsumption: true) == nil)
        #expect(bytes.withUnsafeBufferPointer { parse($0.span, requireFullConsumption: true) } == nil)
    }
}
