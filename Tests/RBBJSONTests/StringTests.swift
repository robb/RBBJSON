import XCTest

import RBBJSON

@available(iOS 10.0, *)
final class StringTests: XCTestCase {
    func testStringConversion() {
        XCTAssertEqual(String("foo" as JSON), "foo")
        XCTAssertEqual(String(""    as JSON), "")
        XCTAssertEqual(String(123.4 as JSON), nil)
        XCTAssertEqual(String(0     as JSON), nil)
    }
}
