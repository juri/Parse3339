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
