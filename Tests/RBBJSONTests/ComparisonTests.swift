import XCTest

import RBBJSON

final class ComparisonTests: XCTestCase {
    func testHeterogenousSorting() {
        let json = [
            false,
            "c",
            nil,
            3, 123, -2, 0,
            "b",
            [ 1, 2, 3 ],
            [ "one": 1, "zero": 0 ],
            "a",
            true
        ] as [RBBJSON]

        XCTAssertEqual(json.sorted(), [
            [ "one": 1, "zero": 0 ],
            [ 1, 2, 3 ],
            -2,
            0,
            3,
            123,
            "a", "b", "c",
            false,
            true,
            nil,
        ])
    }
}
