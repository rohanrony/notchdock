//
//  notchdockTests.swift
//  notchdockTests
//
//  Created by Rohan Roy on 5/1/26.
//

import XCTest
@testable import notchdock
class notchdockTests: XCTestCase {
    var appState: AppState!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // We use the shared instance for now, but in a real app we might want to inject a mock registry
        appState = AppState.shared
    }

    override func tearDownWithError() throws {
        appState = nil
        super.tearDown()
    }

    func testAppConfigValues() throws {
        // Verify default values from AppConfig (assuming default JSON or fallbacks)
        XCTAssertGreaterThan(AppConfig.App.defaultNotchWidth, 0)
        XCTAssertEqual(AppConfig.App.homeViewLimit, 5)
        XCTAssertEqual(AppConfig.App.panelWidth, 400)
    }

    func testAppStateInitialState() throws {
        XCTAssertFalse(appState.isExpanded)
        XCTAssertFalse(appState.isPinned)
        XCTAssertEqual(appState.activeExtensionID, "com.notchdock.calendar")
        XCTAssertTrue(appState.enabledExtensionIDs.contains("com.notchdock.calendar"))
        XCTAssertTrue(appState.extensionOrder.contains("com.notchdock.calendar"))
    }

    func testIntelligentSelectionLogic() throws {
        // Initially, it should be calendar
        XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.calendar")
        
        // Mock nudge active
        appState.isNudgeActive = true
        XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.calendar", "Should still be calendar when nudge is active since calendar has priority 2")
        
        // Mock manual selection of another module
        appState.activeExtensionID = "com.notchdock.music"
        // Note: Music has a compact view, so it should be shown if no higher priority (Timer/Nudge) is active.
        // Wait, the logic is:
        // 1. Timer Critical
        // 2. Calendar Nudge
        // 3. Active Utilities (isLive)
        // 4. Manual Selection
        // 5. Fallback Calendar
        
        appState.isNudgeActive = false
        appState.activeExtensionID = "com.notchdock.music"
        XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.music", "Should show manually selected music if it has compact view")
        
        // Reset to calendar
        appState.activeExtensionID = "com.notchdock.calendar"
    }
    
    func testNudgeAcknowledgement() throws {
        appState.isNudgeActive = true
        appState.acknowledgeNudge()
        XCTAssertFalse(appState.isNudgeActive)
    }
}
