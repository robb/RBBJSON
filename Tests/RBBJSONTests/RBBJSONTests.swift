import XCTest

import RBBJSON

final class RBBJSONTests: XCTestCase {
    func testJSONDecoding() throws {
        let jsonString = """
        {
            "results": [
                {
                    "number": -123.45,
                    "boolean": false,
                    "string": "Hello World",
                },
                {},
                null
            ]
        }
        """

        let json = try JSONDecoder().decode(RBBJSON.self, from: jsonString.data(using: .utf8)!)

        XCTAssertEqual(json, [
            "results": [
                [
                    "number": -123.45,
                    "boolean": false,
                    "string": "Hello World"
                ],
                [:],
                nil
            ]
        ])
    }

    func testJSONRoundTripping() throws {
        let json = [
            "results": [
                [
                    "number": -123.45,
                    "boolean": false,
                    "string": "Hello World"
                ]
            ]
        ] as RBBJSON

        let jsonData = try JSONEncoder().encode(json)

        XCTAssertEqual(json, try JSONDecoder().decode(RBBJSON.self, from: jsonData))
    }

    func testDebugDescription() {
        let json = [
            "results": [
                [
                    "number": -123.45,
                    "boolean": false,
                    "string": "Hello World"
                ]
            ]
        ] as RBBJSON


        XCTAssert(json.debugDescription.contains("Hello World"))
    }

    func testDynamicKeypath() {
        let json = [
            "results": [
                [
                    "number": -123.45,
                    "boolean": false,
                    "string": "Hello World"
                ]
            ]
        ] as RBBJSON

        XCTAssertEqual(json.results[0].number, -123.45)
        XCTAssertEqual(json.results[0].boolean, false)
        XCTAssertEqual(json.results[0].string, "Hello World")
    }

    func testKeys() {
        XCTAssertEqual(RBBJSON.keys("a"), [])
        XCTAssertEqual(RBBJSON.keys(1), [])
        XCTAssertEqual(RBBJSON.keys(false), [])
        XCTAssertEqual(RBBJSON.keys(nil), [])
        XCTAssertEqual(RBBJSON.keys([1, 2, 3]), [])
        XCTAssertEqual(RBBJSON.keys(["a": 1, "b": 2]), ["a", "b"])
    }

    func testValues() {
        XCTAssertEqual(RBBJSON.values("a"), [])
        XCTAssertEqual(RBBJSON.values(1), [])
        XCTAssertEqual(RBBJSON.values(false), [])
        XCTAssertEqual(RBBJSON.values(nil), [])
        XCTAssertEqual(RBBJSON.values([1, 2, 3]), [1, 2, 3])
        XCTAssertEqual(RBBJSON.values(["a": 1, "b": 2]), [1, 2])
    }
}
