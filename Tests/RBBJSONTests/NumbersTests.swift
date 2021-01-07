import XCTest

import RBBJSON

@available(iOS 10.0, *)
final class NumbersTests: XCTestCase {
    func testNumberConversion() {
        do {
            XCTAssertEqual(Int("foo" as RBBJSON), nil)
            XCTAssertEqual(Int(""    as RBBJSON), nil)
            XCTAssertEqual(Int("123.4" as RBBJSON), nil)
            XCTAssertEqual(Int(123.4 as RBBJSON), 123)
            XCTAssertEqual(Int(0     as RBBJSON), 0)

            XCTAssertEqual(Int("foo" as RBBJSON, lenient: true), nil)
            XCTAssertEqual(Int(""    as RBBJSON, lenient: true), nil)
            XCTAssertEqual(Int("123" as RBBJSON, lenient: true), 123)
            XCTAssertEqual(Int("123.4" as RBBJSON, lenient: true), 123)
            XCTAssertEqual(Int(123.4 as RBBJSON, lenient: true), 123)
            XCTAssertEqual(Int(0     as RBBJSON, lenient: true), 0)
        }

        do {
            XCTAssertEqual(UInt32("foo" as RBBJSON), nil)
            XCTAssertEqual(UInt32(""    as RBBJSON), nil)
            XCTAssertEqual(UInt32("123.4" as RBBJSON), nil)
            XCTAssertEqual(UInt32(123.4 as RBBJSON), 123)
            XCTAssertEqual(UInt32(0     as RBBJSON), 0)

            XCTAssertEqual(UInt32("foo" as RBBJSON, lenient: true), nil)
            XCTAssertEqual(UInt32(""    as RBBJSON, lenient: true), nil)
            XCTAssertEqual(UInt32("123" as RBBJSON, lenient: true), 123)
            XCTAssertEqual(UInt32("123.4" as RBBJSON, lenient: true), 123)
            XCTAssertEqual(UInt32(123.4 as RBBJSON, lenient: true), 123)
            XCTAssertEqual(UInt32(0     as RBBJSON, lenient: true), 0)
        }

        #if canImport(CoreGraphics)
        do {
            XCTAssertEqual(CGFloat("foo" as RBBJSON), nil)
            XCTAssertEqual(CGFloat(""    as RBBJSON), nil)
            XCTAssertEqual(CGFloat("123.4" as RBBJSON), nil)
            XCTAssertEqual(CGFloat(123.4 as RBBJSON), 123.4)
            XCTAssertEqual(CGFloat(0     as RBBJSON), 0)

            XCTAssertEqual(CGFloat("foo" as RBBJSON, lenient: true), nil)
            XCTAssertEqual(CGFloat(""    as RBBJSON, lenient: true), nil)
            XCTAssertEqual(CGFloat("123.4" as RBBJSON, lenient: true), 123.4)
            XCTAssertEqual(CGFloat(123.4 as RBBJSON, lenient: true), 123.4)
            XCTAssertEqual(CGFloat(0     as RBBJSON, lenient: true), 0)
        }
        #endif

        do {
            XCTAssertEqual(Double("foo" as RBBJSON), nil)
            XCTAssertEqual(Double(""    as RBBJSON), nil)
            XCTAssertEqual(Double("123.4" as RBBJSON), nil)
            XCTAssertEqual(Double(123.4 as RBBJSON), 123.4)
            XCTAssertEqual(Double(0     as RBBJSON), 0)

            XCTAssertEqual(Double("foo" as RBBJSON, lenient: true), nil)
            XCTAssertEqual(Double(""    as RBBJSON, lenient: true), nil)
            XCTAssertEqual(Double("123.4" as RBBJSON, lenient: true), 123.4)
            XCTAssertEqual(Double(123.4 as RBBJSON, lenient: true), 123.4)
            XCTAssertEqual(Double(0     as RBBJSON, lenient: true), 0)
        }

        do {
            XCTAssertEqual(Float("foo" as RBBJSON), nil)
            XCTAssertEqual(Float(""    as RBBJSON), nil)
            XCTAssertEqual(Float("123.4" as RBBJSON), nil)
            XCTAssertEqual(Float(123.4 as RBBJSON), 123.4)
            XCTAssertEqual(Float(0     as RBBJSON), 0)

            XCTAssertEqual(Float("foo" as RBBJSON, lenient: true), nil)
            XCTAssertEqual(Float(""    as RBBJSON, lenient: true), nil)
            XCTAssertEqual(Float("123.4" as RBBJSON, lenient: true), 123.4)
            XCTAssertEqual(Float(123.4 as RBBJSON, lenient: true), 123.4)
            XCTAssertEqual(Float(0     as RBBJSON, lenient: true), 0)
        }
    }
}
