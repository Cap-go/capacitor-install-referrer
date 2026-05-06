import XCTest
@testable import InstallReferrerPlugin

class InstallReferrerTests: XCTestCase {
    func testGetPluginVersion() {
        let implementation = InstallReferrer()
        let result = implementation.getPluginVersion()

        XCTAssertEqual("native", result)
    }
}
