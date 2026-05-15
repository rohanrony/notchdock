//
//  NotchDockTests.swift
//  NotchDockTests
//
//  Created by Rohan Roy on 5/1/26.
//

import XCTest
@testable import NotchDock

class NotchDockTests: XCTestCase {
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
        // 1. Reset to a known state
        appState.isNudgeActive = false
        appState.activeExtensionID = "com.notchdock.calendar"
        
        // 2. Check initial priority (Live vs Fallback)
        let liveIDs = appState.registry.availableExtensions.filter { $0.isLive }.map { $0.id }
        if let firstLive = liveIDs.first {
            XCTAssertEqual(appState.effectiveCompactExtensionID, firstLive, "Priority: Live module \(firstLive) should be shown")
        } else {
            XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.calendar", "Priority: Fallback should be calendar")
        }
        
        // 3. Test Manual Override (if no live modules)
        if liveIDs.isEmpty {
            appState.activeExtensionID = "com.notchdock.music"
            XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.music", "Priority: Manual selection should show Music")
            appState.activeExtensionID = "com.notchdock.calendar" // Reset
        }
        
        // 4. Test Nudge Priority
        appState.isNudgeActive = true
        XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.calendar", "Priority: Nudge should always show Calendar")
        
        appState.isNudgeActive = false
        appState.activeExtensionID = "com.notchdock.music"
        XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.music")
        
        // Reset to calendar
        appState.activeExtensionID = "com.notchdock.calendar"
    }
    
    func testNudgeAcknowledgement() throws {
        appState.isNudgeActive = true
        appState.acknowledgeNudge()
        XCTAssertFalse(appState.isNudgeActive)
    }

    func testExtensionRegistryCompleteness() throws {
        let expectedIDs = [
            "com.notchdock.calendar",
            "com.notchdock.todo",
            "com.notchdock.music",
            "com.notchdock.timer",
            "com.notchdock.quickaccess"
        ]
        
        let registeredIDs = appState.registry.availableExtensions.map { $0.id }
        for id in expectedIDs {
            XCTAssertTrue(registeredIDs.contains(id), "Module \(id) should be registered")
        }
        XCTAssertEqual(registeredIDs.count, 5, "Total registered modules should be 5")
    }

    func testAppleScriptSanitization() throws {
        let input = "Hello \"World\" \\ Path"
        let expected = "Hello \\\"World\\\" \\\\ Path"
        XCTAssertEqual(input.sanitizedForAppleScript(), expected)
    }

    func testQuickAccessItemManagement() throws {
        let viewModel = QuickAccessViewModel.shared
        let initialCount = viewModel.items.count
        
        viewModel.addItem(heading: "Test Heading", content: "Test Content")
        XCTAssertEqual(viewModel.items.count, initialCount + 1)
        XCTAssertEqual(viewModel.items.last?.heading, "Test Heading")
        
        if let lastItem = viewModel.items.last {
            viewModel.deleteItem(lastItem)
            XCTAssertEqual(viewModel.items.count, initialCount)
        }
    }

    func testEffectiveCompactSelectionPriorities() throws {
        // Reset state
        appState.isNudgeActive = false
        appState.activeExtensionID = "com.notchdock.calendar"
        
        // Priority 1: Timer Critical (we have to mock the TimerViewModel.shared.isCritical somehow or just assume it works if we can't)
        // Since we can't easily mock the singleton for a simple unit test without more refactoring, 
        // we'll focus on Nudge vs Active vs Manual.

        // Priority 2: Calendar Nudge
        appState.isNudgeActive = true
        XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.calendar")

        // Priority 3: Manual selection with compact view
        appState.isNudgeActive = false
        appState.activeExtensionID = "com.notchdock.music"
        // Music has compactView = true by default
        XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.music")
    }

    func testAppConfigLoading() throws {
        // Verify default values from JSON
        XCTAssertEqual(AppConfig.App.panelWidth, 400.0)
        XCTAssertEqual(AppConfig.App.homeViewLimit, 5)
        
        // Verify a nested value
        let threshold = AppConfig.shared.value(for: "calendar", key: "minimized_threshold", default: 0)
        XCTAssertEqual(threshold, 60)
    }

    func testToDoLogic() throws {
        let viewModel = ToDoViewModel.shared
        let initialCount = viewModel.items.count
        
        viewModel.addItem(text: "Unit Test Task")
        XCTAssertEqual(viewModel.items.count, initialCount + 1)
        
        if let newItem = viewModel.items.last {
            XCTAssertFalse(newItem.isCompleted)
            viewModel.toggleItem(newItem)
            XCTAssertTrue(viewModel.items.last?.isCompleted ?? false)
            
            viewModel.deleteItem(newItem)
            XCTAssertEqual(viewModel.items.count, initialCount)
        }
    }

    func testMusicPlayerEnum() throws {
        XCTAssertEqual(MusicManager.PlayerApp.music.bundleID, "com.apple.Music")
        XCTAssertEqual(MusicManager.PlayerApp.spotify.bundleID, "com.spotify.client")
    }

    func testTimerLogic() throws {
        let viewModel = TimerViewModel.shared
        viewModel.reset()
        
        // Default duration
        XCTAssertEqual(viewModel.timeRemaining, TimeInterval(viewModel.defaultMinutes * 60))
        
        // Manual set
        viewModel.setTime(from: "05:30")
        XCTAssertEqual(viewModel.timeRemaining, 330)
        
        // Start/Stop
        viewModel.start()
        XCTAssertTrue(viewModel.isRunning)
        viewModel.pause()
        XCTAssertFalse(viewModel.isRunning)
        
        // Critical state
        viewModel.setTime(from: "00:59")
        viewModel.start()
        XCTAssertTrue(viewModel.isCritical)
        viewModel.pause()
        
        viewModel.reset()
    }

    func testMusicViewModelInitialState() throws {
        let viewModel = MusicViewModel.shared
        XCTAssertEqual(viewModel.trackTitle, "Not Playing")
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertEqual(viewModel.progress, 0.0)
    }

    func testAppStateModuleSwitching() throws {
        // Ensure we can switch and it updates correctly
        appState.activeExtensionID = "com.notchdock.todo"
        XCTAssertEqual(appState.activeExtensionID, "com.notchdock.todo")
        
        appState.activeExtensionID = "com.notchdock.timer"
        XCTAssertEqual(appState.activeExtensionID, "com.notchdock.timer")
    }

    func testCalendarNudgeLogic() throws {
        // Nudge should activate when requested
        appState.isNudgeActive = false
        appState.activeExtensionID = "com.notchdock.music"
        
        appState.isNudgeActive = true
        XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.calendar", "Nudge should override active module in compact view")
        
        appState.acknowledgeNudge()
        XCTAssertFalse(appState.isNudgeActive)
        XCTAssertEqual(appState.effectiveCompactExtensionID, "com.notchdock.music", "After nudge acknowledgment, should return to active module")
    }
}
