import XCTest

import RBBJSON

private let json = [
    "store": [
        "book": [
            [
                "category": "reference",
                "author": "Nigel Rees",
                "title": "Sayings of the Century",
                "price": 8.95
            ],
            [
                "category": "fiction",
                "author": "Evelyn Waugh",
                "title": "Sword of Honour",
                "price": 12.99
            ],
            [
                "category": "fiction",
                "author": "Herman Melville",
                "title": "Moby Dick",
                "isbn": "0-553-21311-3",
                "price": 8.99
            ],
            [
                "category": "fiction",
                "author": "J. R. R. Tolkien",
                "title": "The Lord of the Rings",
                "isbn": "0-395-19395-8",
                "price": 22.99
            ]
        ],
        "bicycle": [
            "color": "red",
            "price": 19.95
        ]
    ],
    "expensive": 10
] as RBBJSON

final class QueryTests: XCTestCase {
    func testQueriesMultipleIndices() {
        // JSONPath: $..book[0,1].price
        RBBAssertEqual(json[any: .descendantOrSelf].book[0, 1].price, [
            8.95,
            12.99
        ])
    }

    func testQueriesMultipleNegativeIndices() {
        // JSONPath: $..book[-4,-3].price
        RBBAssertEqual(json[any: .descendantOrSelf].book[-4, -3].price, [
            8.95,
            12.99
        ])
    }

    func testRange() {
        // JSONPath: $..book[1:2]
        RBBAssertEqual(json[any: .descendantOrSelf].book[1..<2], [
            [
                "category": "fiction",
                "author": "Evelyn Waugh",
                "title": "Sword of Honour",
                "price": 12.99
            ]
        ])
    }

    func testPredicateOnObject() {
        // JSONPath: $.store.bicycle[?(@.price < 20)]
        RBBAssertEqual(json.store.bicycle[matches: { $0.price <= 20 }], [
            [
                "color": "red",
                "price": 19.95
            ]
        ])

        // JSONPath: $.store.bicycle[?(@.price <= 20)].color
        RBBAssertEqual(json.store.bicycle[matches: { $0.price <= 20 }].color, [
            "red"
        ])

        // JSONPath: $.store[*][?(@.price <= 20)].color
        //
        // NOTE: This query doesn't seem to work in Gatling but does in Jayway.
        RBBAssertEqual(json.store[any: .child][matches: { $0.price <= 20 }].color, [
            "red"
        ])
    }

    func testTrailingAnyOnArray() {
        // JSONPath: $.store.books[*]
        RBBAssertEqual(json.store.book[any: .child], [
            [
                "category": "reference",
                "author": "Nigel Rees",
                "title": "Sayings of the Century",
                "price": 8.95
            ],
            [
                "category": "fiction",
                "author": "Evelyn Waugh",
                "title": "Sword of Honour",
                "price": 12.99
            ],
            [
                "category": "fiction",
                "author": "Herman Melville",
                "title": "Moby Dick",
                "isbn": "0-553-21311-3",
                "price": 8.99
            ],
            [
                "category": "fiction",
                "author": "J. R. R. Tolkien",
                "title": "The Lord of the Rings",
                "isbn": "0-395-19395-8",
                "price": 22.99
            ]
        ])
    }

    func testLaziness() {
        var counter = 0;

        let json = [
            1, "b", "c", 4
        ] as RBBJSON

        XCTAssertEqual(counter, 0)

        let query = json[matches: { _ in
            counter += 1;

            return true == true
        }]

        var results = query.lazy.map { $0 }.makeIterator()

        XCTAssertEqual(counter, 0)

        XCTAssertEqual(results.next(), 1)
        XCTAssertEqual(counter, 1)

        XCTAssertEqual(results.next(), "b")
        XCTAssertEqual(counter, 2)

        XCTAssertEqual(results.next(), "c")
        XCTAssertEqual(counter, 3)
    }

    func testEagerness() {
        var counter = 0;

        let json = [
            1, "b", "c", 4
        ] as RBBJSON

        XCTAssertEqual(counter, 0)

        let query = json[matches: { _ in
            counter += 1;

            return true == true
        }]

        var results = query.map { $0 }.makeIterator()

        XCTAssertEqual(counter, 4)

        XCTAssertEqual(results.next(), 1)
        XCTAssertEqual(counter, 4)

        XCTAssertEqual(results.next(), "b")
        XCTAssertEqual(counter, 4)

        XCTAssertEqual(results.next(), "c")
        XCTAssertEqual(counter, 4)
    }

    func testOrder() {
        let json = [
            "numbers": [
                [1],
                [2],
                [3],
                [4],
            ]
        ] as RBBJSON

        RBBAssertEqual(json[any: .child][any: .child][any: .child], [1, 2, 3, 4])
        RBBAssertEqual(json[any: .child][any: .child][0], [1, 2, 3, 4])
        RBBAssertEqual(json[any: .child][0, 1, 2, 3][0], [1, 2, 3, 4])
        RBBAssertEqual(json[any: .child][0..<4][0], [1, 2, 3, 4])
        RBBAssertEqual(json[any: .child][0...3][0], [1, 2, 3, 4])
        RBBAssertEqual(json.numbers[any: .child][0], [1, 2, 3, 4])
        RBBAssertEqual(json.numbers[matches: { $0[0] >= 0 }][any: .child], [1, 2, 3, 4])
    }

    func testEmptyLeaves() {
        let json = [
            [
                [:],
                ["empty": [:]],
                ["also_empty": []],
                []
            ],
            []
        ] as RBBJSON

        let result = Array(json[any: .child][any: .child][any: .child][any: .child])

        XCTAssert(result.isEmpty)
    }

    func testUnsupported() {
        do {
            let result = Array(json.store.bicycle[1, 2, 3])

            XCTAssert(result.isEmpty)
        }

        do {
            let result = Array(json.store.bicycle[1..<3])

            XCTAssert(result.isEmpty)
        }

        do {
            let result = Array(json.store.books["a"])

            XCTAssert(result.isEmpty)
        }
    }

    func testFilters() throws {
        let json = [
            [
                "name": "a",
                "flag": nil
            ],
            [
                "name": "b",
                "flag": 5
            ],
            [
                "name": "c",
                "flag": 10
            ]
        ] as RBBJSON

        RBBAssertEqual(json[has: \.name].name, ["a", "b", "c"])
        RBBAssertEqual(json[has: \.flag].name, ["b", "c"])
        RBBAssertEqual(json[has: \.flag][matches: { $0.flag >= 7 }].name, [
            "c"
        ])
    }
}

func RBBAssertEqual<S, T>(_ lhs: S, _ result: T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) where S: Sequence, T: Sequence, T.Element == S.Element, S.Element: Equatable {
    XCTAssertEqual(Array(lhs), Array(result), message(), file: file, line: line)
}
