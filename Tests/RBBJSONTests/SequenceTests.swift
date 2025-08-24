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
        ] as JSON

        for results in JSON.values(json) {
            for result in JSON.values(results) {
                XCTAssertEqual(result.number, -123.45)
                XCTAssertEqual(result.boolean, false)
                XCTAssertEqual(result.string, "Hello World")
            }
        }
    }
}
