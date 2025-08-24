import XCTest

import RBBJSON

final class SequenceWrapperTests: XCTestCase {
    func testQueriesAny() {
        let json = [
            "office": [
                "name": "BER01",
                "map": "https://maps.apple.com/place?name=BER01&place-id=I8449F78C791DD502"
            ]
        ] as JSON

        RBBAssertEqual(json[any: .child].map, ["https://maps.apple.com/place?name=BER01&place-id=I8449F78C791DD502"])
    }
}
