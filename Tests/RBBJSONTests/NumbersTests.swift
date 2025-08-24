import XCTest

import RBBJSON

@available(iOS 10.0, *)
final class NumbersTests: XCTestCase {
    func testNumberConversion() {
        do {
            XCTAssertEqual(Int("foo" as JSON), nil)
            XCTAssertEqual(Int(""    as JSON), nil)
            XCTAssertEqual(Int("123.4" as JSON), nil)
            XCTAssertEqual(Int(123.4 as JSON), 123)
            XCTAssertEqual(Int(0     as JSON), 0)

            XCTAssertEqual(Int("foo" as JSON, lenient: true), nil)
            XCTAssertEqual(Int(""    as JSON, lenient: true), nil)
            XCTAssertEqual(Int("123" as JSON, lenient: true), 123)
            XCTAssertEqual(Int("123.4" as JSON, lenient: true), 123)
            XCTAssertEqual(Int(123.4 as JSON, lenient: true), 123)
            XCTAssertEqual(Int(0     as JSON, lenient: true), 0)
        }

        do {
            XCTAssertEqual(UInt32("foo" as JSON), nil)
            XCTAssertEqual(UInt32(""    as JSON), nil)
            XCTAssertEqual(UInt32("123.4" as JSON), nil)
            XCTAssertEqual(UInt32(123.4 as JSON), 123)
            XCTAssertEqual(UInt32(0     as JSON), 0)

            XCTAssertEqual(UInt32("foo" as JSON, lenient: true), nil)
            XCTAssertEqual(UInt32(""    as JSON, lenient: true), nil)
            XCTAssertEqual(UInt32("123" as JSON, lenient: true), 123)
            XCTAssertEqual(UInt32("123.4" as JSON, lenient: true), 123)
            XCTAssertEqual(UInt32(123.4 as JSON, lenient: true), 123)
            XCTAssertEqual(UInt32(0     as JSON, lenient: true), 0)
        }

        #if canImport(CoreGraphics)
        do {
            XCTAssertEqual(CGFloat("foo" as JSON), nil)
            XCTAssertEqual(CGFloat(""    as JSON), nil)
            XCTAssertEqual(CGFloat("123.4" as JSON), nil)
            XCTAssertEqual(CGFloat(123.4 as JSON), 123.4)
            XCTAssertEqual(CGFloat(0     as JSON), 0)

            XCTAssertEqual(CGFloat("foo" as JSON, lenient: true), nil)
            XCTAssertEqual(CGFloat(""    as JSON, lenient: true), nil)
            XCTAssertEqual(CGFloat("123.4" as JSON, lenient: true), 123.4)
            XCTAssertEqual(CGFloat(123.4 as JSON, lenient: true), 123.4)
            XCTAssertEqual(CGFloat(0     as JSON, lenient: true), 0)
        }
        #endif

        do {
            XCTAssertEqual(Double("foo" as JSON), nil)
            XCTAssertEqual(Double(""    as JSON), nil)
            XCTAssertEqual(Double("123.4" as JSON), nil)
            XCTAssertEqual(Double(123.4 as JSON), 123.4)
            XCTAssertEqual(Double(0     as JSON), 0)

            XCTAssertEqual(Double("foo" as JSON, lenient: true), nil)
            XCTAssertEqual(Double(""    as JSON, lenient: true), nil)
            XCTAssertEqual(Double("123.4" as JSON, lenient: true), 123.4)
            XCTAssertEqual(Double(123.4 as JSON, lenient: true), 123.4)
            XCTAssertEqual(Double(0     as JSON, lenient: true), 0)
        }

        do {
            XCTAssertEqual(Float("foo" as JSON), nil)
            XCTAssertEqual(Float(""    as JSON), nil)
            XCTAssertEqual(Float("123.4" as JSON), nil)
            XCTAssertEqual(Float(123.4 as JSON), 123.4)
            XCTAssertEqual(Float(0     as JSON), 0)

            XCTAssertEqual(Float("foo" as JSON, lenient: true), nil)
            XCTAssertEqual(Float(""    as JSON, lenient: true), nil)
            XCTAssertEqual(Float("123.4" as JSON, lenient: true), 123.4)
            XCTAssertEqual(Float(123.4 as JSON, lenient: true), 123.4)
            XCTAssertEqual(Float(0     as JSON, lenient: true), 0)
        }
    }
}
