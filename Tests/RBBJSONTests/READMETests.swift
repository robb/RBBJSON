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

final class READMETests: XCTestCase {
    func testQueriesAny() {
        // JSONPath: $.store.book[*].author
        RBBAssertEqual(json.store.book[any: .child].author, [
            "Nigel Rees",
            "Evelyn Waugh",
            "Herman Melville",
            "J. R. R. Tolkien"
        ])
    }

    func testQueriesDescend() {
        // JSONPath: $..author
        RBBAssertEqual(json[any: .descendantOrSelf].author, [
            "Nigel Rees",
            "Evelyn Waugh",
            "Herman Melville",
            "J. R. R. Tolkien"
        ])
    }

    func testQueriesAnyAtEnd() {
        // JSONPath: $.store.*
        RBBAssertEqual(json.store[any: .child], [
            [
                "color": "red",
                "price": 19.95
            ],
            [
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
            ]
        ])
    }

    func testQueriesDescend2() {
        // JSONPath: $.store..price
        RBBAssertEqual(json.store[any: .descendantOrSelf].price, [
            19.95,
            8.95,
            12.99,
            8.99,
            22.99
        ])
    }

    func testQueriesSingleIndex() {
        // JSONPath: $..book[2]
        RBBAssertEqual(json[any: .descendantOrSelf].book[2], [
            [
                "category": "fiction",
                "author": "Herman Melville",
                "title": "Moby Dick",
                "isbn": "0-553-21311-3",
                "price": 8.99
            ]
        ])
    }

    func testQueriesNegativeIndex() {
        // JSONPath: $..book[-2]
        RBBAssertEqual(json[any: .descendantOrSelf].book[-2], [
            [
                "category": "fiction",
                "author": "Herman Melville",
                "title": "Moby Dick",
                "isbn": "0-553-21311-3",
                "price": 8.99
            ]
        ])
    }

    func testQueriesMultipleIndicesAtEnd() {
        // JSONPath: $..book[0,1]
        RBBAssertEqual(json[any: .descendantOrSelf].book[0, 1], [
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
            ]
        ])
    }

    func testFilter() {
        // JSONPath: $..book[?(@.isbn)]
        RBBAssertEqual(json[any: .descendantOrSelf].book[has: \.isbn], [
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

    func testBooleanPredicate() {
        // JSONPath: $.store.book[?(@.price < 10)]
        RBBAssertEqual(json.store.book[matches: { $0.price <= 10 }], [
            [
                "category": "reference",
                "author": "Nigel Rees",
                "title": "Sayings of the Century",
                "price": 8.95
            ],
            [
                "category": "fiction",
                "author": "Herman Melville",
                "title": "Moby Dick",
                "isbn": "0-553-21311-3",
                "price": 8.99
            ]
        ])
    }

    func testMultipleKeys() {
        // JSONPath: $.store["book", "bicycle"]..["price", "author"]
        //
        // NOTE: This query doesn't seem to work in Gatling but does in Jayway
        //       with slightly different semantics: Turning on _Return null for
        //       missing leaf_ will produce the expected result although with a
        //       `null` value for the bicycle's author that we're omitting here.
        RBBAssertEqual(json.store["book", "bicycle"][any: .descendantOrSelf]["price", "author"], [
            [
                "price": 19.95,
            ],
            [
                "price": 8.95,
                "author": "Nigel Rees"
            ],
            [
                "price": 12.99,
                "author": "Evelyn Waugh"
            ],
            [
                "price": 8.99,
                "author": "Herman Melville"
            ],
            [
                "price": 22.99,
                "author": "J. R. R. Tolkien"
            ],
        ])
    }

    func testExample() {
        RBBAssertEqual(json.store.book[0].title.compactMap(String.init),    [
            "Sayings of the Century"
        ])
        RBBAssertEqual(json.store.book[0, 1].title.compactMap(String.init), [
            "Sayings of the Century",
            "Sword of Honour"
        ])

        RBBAssertEqual(json.store.book[0]["invalid Property"].compactMap(String.init),    [])
        RBBAssertEqual(json.store.book[0, 1]["invalid Property"].compactMap(String.init), [])

    }
}
