import XCTest

import RBBJSON

@available(iOS 10.0, *)
final class OpticsTests: XCTestCase {
    func testMap() {
        let foo: JSON = "Hello, World!"
        let bar: JSON = 123456

        XCTAssertEqual(foo.ƒ.map(.string) { $0.uppercased() }, "HELLO, WORLD!")
        XCTAssertEqual(bar.ƒ.map(.string) { $0.uppercased() }, 123456)
    }

    func testFlatMap() {
        let foo: JSON = "Hello, World!"
        let bar: JSON = 123456

        XCTAssertEqual(foo.ƒ.flatMap(.string) { [.string($0.uppercased())] }, ["HELLO, WORLD!"])
        XCTAssertEqual(bar.ƒ.flatMap(.string) { [.string($0.uppercased())] }, 123456)
    }

    func testModify() {
        let object: JSON = [
            "foo": "Hello, World!",
            "bar": 123456
        ]

        let a = object
            .ƒ.modify(\.foo, as: .string) { $0.uppercased() }

        XCTAssertEqual(a, [
            "foo": "HELLO, WORLD!",
            "bar": 123456
        ])

        let b = object
            .ƒ.modify(\.foo, as: .string) { $0.uppercased() }
            .ƒ.modify(\.bar, as: .double) { $0 + 1 }

        XCTAssertEqual(b, [
            "foo": "HELLO, WORLD!",
            "bar": 123457
        ])
    }
}
