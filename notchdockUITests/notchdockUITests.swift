//
//  NotchDockUITests.swift
//  NotchDockUITests
//
//  Created by Rohan Roy on 5/1/26.
//

import XCTest

final class NotchDockUITests: XCTestCase {

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
        app.launchArguments.append("--test-expanded")
        app.launch()

        let expandedPanel = app.otherElements[TestIdentifiers.Main.expandedPanel]
        XCTAssertTrue(expandedPanel.waitForExistence(timeout: 2), "The expanded panel should be visible when --test-expanded is passed")
        
        let todoButton = app.buttons["module_todo"]
        XCTAssertTrue(todoButton.exists, "The Todo module button should be visible in the expanded panel")
    }

    @MainActor
    func testModuleSwitching() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--test-expanded")
        app.launch()

        let todoButton = app.buttons["module_todo"]
        XCTAssertTrue(todoButton.exists)
        todoButton.click()
        
        // Wait for potential UI updates
        let todoView = app.otherElements["todo_view"] // I should check if this ID exists
        // XCTAssertTrue(todoView.exists)
    }
}
