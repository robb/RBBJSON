import XCTest

import RBBJSON

@available(iOS 10.0, *)
final class BoolTests: XCTestCase {
    func testBooleanConversion() {
        XCTAssertEqual(Bool("foo"   as RBBJSON), nil)
        XCTAssertEqual(Bool(""      as RBBJSON), nil)
        XCTAssertEqual(Bool("false" as RBBJSON), nil)
        XCTAssertEqual(Bool("true"  as RBBJSON), nil)
        XCTAssertEqual(Bool(0       as RBBJSON), nil)
        XCTAssertEqual(Bool(1       as RBBJSON), nil)
        XCTAssertEqual(Bool(3       as RBBJSON), nil)
        XCTAssertEqual(Bool(true    as RBBJSON), true)
        XCTAssertEqual(Bool(false   as RBBJSON), false)

        XCTAssertEqual(Bool("foo"   as RBBJSON, lenient: true), nil)
        XCTAssertEqual(Bool(""      as RBBJSON, lenient: true), nil)
        XCTAssertEqual(Bool("false" as RBBJSON, lenient: true), false)
        XCTAssertEqual(Bool("true"  as RBBJSON, lenient: true), true)
        XCTAssertEqual(Bool(0       as RBBJSON, lenient: true), false)
        XCTAssertEqual(Bool(1       as RBBJSON, lenient: true), true)
        XCTAssertEqual(Bool(3       as RBBJSON, lenient: true), true)
        XCTAssertEqual(Bool(true    as RBBJSON, lenient: true), true)
        XCTAssertEqual(Bool(false   as RBBJSON, lenient: true), false)
    }
}
