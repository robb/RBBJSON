import XCTest

import RBBJSON

final class SequenceTests: XCTestCase {
    func testEnumeration() {
        let json = [
            "results": [
                [
                    "number": -123.45,
                    "boolean": false,
                    "string": "Hello World"
                ]
            ]
        ] as RBBJSON

        for results in RBBJSON.values(json) {
            for result in RBBJSON.values(results) {
                XCTAssertEqual(result.number, -123.45)
                XCTAssertEqual(result.boolean, false)
                XCTAssertEqual(result.string, "Hello World")
            }
        }

        for value in ["a": 123] as RBBJSON {
            XCTAssert(Double(value.a) ?? 0 >= 0)
        }

        for value in [1, 2, 3] as RBBJSON {
            XCTAssert(Double(value) ?? 0 >= 0)
        }

        for value in 1 as RBBJSON {
            XCTAssertEqual(Double(value), 1)
        }

        for value in true as RBBJSON {
            XCTAssertEqual(Bool(value), true)
        }

        for value in "test" as RBBJSON {
            XCTAssertEqual(String(value), "test")
        }

        for _ in nil as RBBJSON {
            fatalError()
        }
    }
}
