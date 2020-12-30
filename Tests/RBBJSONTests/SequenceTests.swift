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
    }
}
