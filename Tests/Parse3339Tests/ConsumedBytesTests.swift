@testable import Parse3339
import Testing

@Suite struct ConsumedBytesNoTrailingJunkTests {
    @Test func `tz stamp with fractions`() throws {
        let s = "2023-07-04T08:21:25.2+03:00"
        let p = try #require(parse(s))
        #expect(p.consumedBytes == s.utf8.count)
    }

    @Test func `z stamp with fractions`() throws {
        let s = "2023-07-04T08:21:25.90Z"
        let p = try #require(parse(s))
        #expect(p.consumedBytes == s.utf8.count)
    }

    @Test func `tz stamp terminating in seconds`() throws {
        let s = "2023-07-04T08:21:25+01:23"
        let p = try #require(parse(s))
        #expect(p.consumedBytes == s.utf8.count)
    }

    @Test func `z stamp terminating in seconds`() throws {
        let s = "2023-07-04T08:21:25Z"
        let p = try #require(parse(s))
        #expect(p.consumedBytes == s.utf8.count)
    }
}

@Suite struct ConsumedBytesNoTrailingJunkRequireFullConsumptionTests {
    @Test func `tz stamp with fractions`() throws {
        let s = "2023-07-04T08:21:25.2+03:00"
        let p = try #require(parse(s, requireFullConsumption: true))
        #expect(p.consumedBytes == s.utf8.count)
    }

    @Test func `z stamp with fractions`() throws {
        let s = "2023-07-04T08:21:25.90Z"
        let p = try #require(parse(s, requireFullConsumption: true))
        #expect(p.consumedBytes == s.utf8.count)
    }

    @Test func `tz stamp terminating in seconds`() throws {
        let s = "2023-07-04T08:21:25+01:23"
        let p = try #require(parse(s, requireFullConsumption: true))
        #expect(p.consumedBytes == s.utf8.count)
    }

    @Test func `z stamp terminating in seconds`() throws {
        let s = "2023-07-04T08:21:25Z"
        let p = try #require(parse(s, requireFullConsumption: true))
        #expect(p.consumedBytes == s.utf8.count)
    }
}

@Suite struct ConsumedBytesWithTrailingJunkTests {
    @Test func `tz stamp with fractions`() throws {
        let s = "2023-07-04T08:21:25.2+03:00"
        let p = try #require(parse("\(s)junk"))
        #expect(p.consumedBytes == s.utf8.count)
    }

    @Test func `z stamp with fractions`() throws {
        let s = "2023-07-04T08:21:25.90Z"
        let p = try #require(parse("\(s)junk"))
        #expect(p.consumedBytes == s.utf8.count)
    }

    @Test func `tz stamp terminating in seconds`() throws {
        let s = "2023-07-04T08:21:25+01:23"
        let p = try #require(parse("\(s)junk"))
        #expect(p.consumedBytes == s.utf8.count)
    }

    @Test func `z stamp terminating in seconds`() throws {
        let s = "2023-07-04T08:21:25Z"
        let p = try #require(parse("\(s)junk"))
        #expect(p.consumedBytes == s.utf8.count)
    }
}

@Suite struct ConsumedBytesWithTrailingJunkRequireFullConsumptionTests {
    @Test func `tz stamp with fractions`() throws {
        let s = "2023-07-04T08:21:25.2+03:00"
        #expect(parse("\(s)junk", requireFullConsumption: true) == nil)
    }

    @Test func `z stamp with fractions`() throws {
        let s = "2023-07-04T08:21:25.90Z"
        #expect(parse("\(s)junk", requireFullConsumption: true) == nil)
    }

    @Test func `tz stamp terminating in seconds`() throws {
        let s = "2023-07-04T08:21:25+01:23"
        #expect(parse("\(s)junk", requireFullConsumption: true) == nil)
    }

    @Test func `z stamp terminating in seconds`() throws {
        let s = "2023-07-04T08:21:25Z"
        #expect(parse("\(s)junk", requireFullConsumption: true) == nil)
    }
}
