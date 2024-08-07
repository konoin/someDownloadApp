//
//  TestDownloaderApp_UITestsLaunchTests.swift
//  TestDownloaderApp_UITests
//
//  Created by Mikita Palyka on 8.07.24.
//

import XCTest

final class TestDownloaderApp_UITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
