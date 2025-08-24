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

        let json = try JSONDecoder().decode(JSON.self, from: jsonString.data(using: .utf8)!)

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
        ] as JSON

        let jsonData = try JSONEncoder().encode(json)

        XCTAssertEqual(json, try JSONDecoder().decode(JSON.self, from: jsonData))
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
        ] as JSON


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
        ] as JSON

        XCTAssertEqual(json.results[0].number, -123.45)
        XCTAssertEqual(json.results[0].boolean, false)
        XCTAssertEqual(json.results[0].string, "Hello World")
    }

    func testKeys() {
        XCTAssertEqual(JSON.keys("a"), [])
        XCTAssertEqual(JSON.keys(1), [])
        XCTAssertEqual(JSON.keys(false), [])
        XCTAssertEqual(JSON.keys(nil), [])
        XCTAssertEqual(JSON.keys([1, 2, 3]), [])
        XCTAssertEqual(JSON.keys(["a": 1, "b": 2]), ["a", "b"])
    }

    func testValues() {
        XCTAssertEqual(JSON.values("a"), [])
        XCTAssertEqual(JSON.values(1), [])
        XCTAssertEqual(JSON.values(false), [])
        XCTAssertEqual(JSON.values(nil), [])
        XCTAssertEqual(JSON.values([1, 2, 3]), [1, 2, 3])
        XCTAssertEqual(JSON.values(["a": 1, "b": 2]), [1, 2])
    }
}
