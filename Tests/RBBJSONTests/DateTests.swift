import XCTest

import RBBJSON

@available(iOS 10.0, *)
final class DateTests: XCTestCase {
    func testDateConversion() {
        XCTAssertEqual(Date("foo" as RBBJSON), nil)

        XCTAssertEqual(Date(1604942100 as RBBJSON), Date(timeIntervalSince1970: 1604942100))
        XCTAssertEqual(Date(1604942100000 as RBBJSON, numberDecodingStrategoy: .millisecondsSince1970), Date(timeIntervalSince1970: 1604942100))

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"

        XCTAssertEqual(Date("2020-11-09T17:15:00Z" as RBBJSON), Date(timeIntervalSince1970: 1604942100))
        XCTAssertEqual(Date("Mon, 9 Nov 2020 17:15:00 +0000" as RBBJSON, stringDecodingStrategoy: .formatted(formatter)), Date(timeIntervalSince1970: 1604942100))
    }
}
