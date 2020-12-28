import XCTest

import RBBJSON

@available(iOS 10.0, *)
final class StringTests: XCTestCase {
    func testStringConversion() {
        XCTAssertEqual(String("foo" as RBBJSON), "foo")
        XCTAssertEqual(String(""    as RBBJSON), "")
        XCTAssertEqual(String(123.4 as RBBJSON), nil)
        XCTAssertEqual(String(0     as RBBJSON), nil)
    }
}
