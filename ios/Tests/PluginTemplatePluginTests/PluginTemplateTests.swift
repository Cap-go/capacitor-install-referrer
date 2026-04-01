import XCTest
@testable import PluginTemplatePlugin

class PluginTemplateTests: XCTestCase {
    func testEcho() {
        let implementation = PluginTemplate()
        let value = "Hello, World!"
        let result = implementation.echo(value)

        XCTAssertEqual(value, result)
    }

    func testGetPluginVersion() {
        let implementation = PluginTemplate()
        let result = implementation.getPluginVersion()

        XCTAssertEqual("native", result)
    }
}
