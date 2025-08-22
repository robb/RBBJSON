import XCTest

@testable import RBBJSON

final class KeyPathTests: XCTestCase {
    func testKeyPaths() {
        let keyPath: WritableKeyPath<RBBJSON.Placeholder, RBBJSON.Placeholder> = \.root.middle.middle.end

        XCTAssertEqual(keyPath.lastComponentName, "end")
    }
}
