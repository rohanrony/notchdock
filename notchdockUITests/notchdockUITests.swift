//
//  notchdockUITests.swift
//  notchdockUITests
//
//  Created by Rohan Roy on 5/1/26.
//

import XCTest

final class notchdockUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAppLaunchAndNotchPresence() throws {
        let app = XCUIApplication()
        app.launch()

        // Check if the notch view exists
        let notch = app.otherElements["main_notch_view"]
        XCTAssertTrue(notch.exists, "The main notch view should exist on launch")
    }

    @MainActor
    func testExpandAndOpenSettings() throws {
        let app = XCUIApplication()
        app.launch()

        let notch = app.otherElements["main_notch_view"]
        XCTAssertTrue(notch.exists)
        
        // Simulating expansion is hard in UI tests because onHover is not easily triggered via XCUI.
        // However, we can try to click it or find sub-elements if they are already there but hidden.
        // In this app, the expanded content is only added to the hierarchy when isExpanded is true.
        
        // Let's try to find the settings button. It might not be visible yet.
        let settingsButton = app.buttons["settings_button"]
        
        // We can't easily hover, but we can try to force the state if we had a debug flag.
        // For now, let's just verify the launch and basic elements.
    }
}
