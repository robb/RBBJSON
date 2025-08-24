import XCTest

@testable import RBBJSON

final class KeyPathTests: XCTestCase {
    func testKeyPaths() {
        let keyPath: WritableKeyPath<JSON.Placeholder, JSON.Placeholder> = \.root.middle.middle.end

        XCTAssertEqual(keyPath.lastComponentName, "end")
    }
}
