import XCTest

import RBBJSON

@available(iOS 10.0, *)
final class BoolTests: XCTestCase {
    func testBooleanConversion() {
        XCTAssertEqual(Bool("foo"   as JSON), nil)
        XCTAssertEqual(Bool(""      as JSON), nil)
        XCTAssertEqual(Bool("false" as JSON), nil)
        XCTAssertEqual(Bool("true"  as JSON), nil)
        XCTAssertEqual(Bool(0       as JSON), nil)
        XCTAssertEqual(Bool(1       as JSON), nil)
        XCTAssertEqual(Bool(3       as JSON), nil)
        XCTAssertEqual(Bool(true    as JSON), true)
        XCTAssertEqual(Bool(false   as JSON), false)

        XCTAssertEqual(Bool("foo"   as JSON, lenient: true), nil)
        XCTAssertEqual(Bool(""      as JSON, lenient: true), nil)
        XCTAssertEqual(Bool("false" as JSON, lenient: true), false)
        XCTAssertEqual(Bool("true"  as JSON, lenient: true), true)
        XCTAssertEqual(Bool(0       as JSON, lenient: true), false)
        XCTAssertEqual(Bool(1       as JSON, lenient: true), true)
        XCTAssertEqual(Bool(3       as JSON, lenient: true), true)
        XCTAssertEqual(Bool(true    as JSON, lenient: true), true)
        XCTAssertEqual(Bool(false   as JSON, lenient: true), false)
    }
}
