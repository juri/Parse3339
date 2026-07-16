@testable import Parse3339
import Testing

@Suite struct UnknownLocalOffsetTests {
    @Test func `parse unknown local offset`() throws {
        let s = "2023-07-04T08:21:25.2-00:00"
        let parsed = try #require(parse(s))
        #expect(parsed.zone == nil)
    }
}
