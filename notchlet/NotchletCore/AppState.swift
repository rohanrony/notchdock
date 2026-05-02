import SwiftUI
import Combine
import Foundation
import EventKit

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isExpanded: Bool = false
    @Published var isPinned: Bool = false
    @Published var activeExtensionID: String? {
        didSet {
            if let id = activeExtensionID {
                lastInteractionTimes[id] = Date()
                // Auto-acknowledge nudge if user manually switches to a live-capable module
                if let ext = registry.availableExtensions.first(where: { $0.id == id }), ext.hasCompactView {
                    acknowledgeNudge()
                }
            }
        }
    }
    @Published var enabledExtensionIDs: Set<String> = []
    @Published var extensionOrder: [String] = []
    @Published var homeViewModuleIDs: Set<String> = []
    @Published var registry: ExtensionRegistry
    @Published var purchaseManager: PurchaseManager
    @Published var detectedNotchWidth: CGFloat = AppConfig.App.defaultNotchWidth
    @Published var detectedMenuBarHeight: CGFloat = AppConfig.App.defaultMenuBarHeight // Default fallback
    
    // Intelligent Selection State
    @Published var lastInteractionTimes: [String: Date] = [:]
    @Published var isNudgeActive: Bool = false
    private var lastNudgeInterval: Int? = nil
    private var nudgeMonitorTimer: Timer?
    
    var effectiveCompactExtensionID: String {
        // 1. Timer Critical (< 60s)
        if TimerViewModel.shared.isCritical {
            return "com.notchlet.timer"
        }
        
        // 2. Calendar Sticky Nudge
        if isNudgeActive {
            return "com.notchlet.calendar"
        }
        
        // 3. Active Utilities (Music/Timer)
        let liveExtensions = registry.availableExtensions.filter { $0.isLive }
        if !liveExtensions.isEmpty {
            // Tie-break by last interaction time
            let sortedLive = liveExtensions.sorted { ext1, ext2 in
                let time1 = lastInteractionTimes[ext1.id] ?? Date.distantPast
                let time2 = lastInteractionTimes[ext2.id] ?? Date.distantPast
                return time1 > time2
            }
            return sortedLive.first!.id
        }
        
        // 4. Manual Selection (if it has a compact view)
        if let activeId = activeExtensionID,
           let ext = registry.availableExtensions.first(where: { $0.id == activeId }),
           ext.hasCompactView {
            return activeId
        }
        
        // 5. Fallback Home State
        return "com.notchlet.calendar"
    }
    
    init() {
        // Detect actual notch width and height if available
        self.detectedNotchWidth = AppState.calculateNotchWidth()
        self.detectedMenuBarHeight = AppState.calculateMenuBarHeight()
        let registry = ExtensionRegistry()
        registry.register(CalendarModule())
        registry.register(ToDoModule())
        registry.register(MusicModule())
        registry.register(TimerModule())
        registry.register(QuickAccessModule())
        
        self.registry = registry
        self.purchaseManager = PurchaseManager()
        
        let defaultOrder = [
            "com.notchlet.calendar",
            "com.notchlet.todo",
            "com.notchlet.music",
            "com.notchlet.timer",
            "com.notchlet.quickaccess"
        ]
        
        let initialEnabled = [
            "com.notchlet.calendar",
            "com.notchlet.todo",
            "com.notchlet.music",
            "com.notchlet.timer",
            "com.notchlet.quickaccess"
        ]
        
        self.extensionOrder = defaultOrder
        self.enabledExtensionIDs = Set(initialEnabled)
        self.activeExtensionID = "com.notchlet.calendar"
        self.homeViewModuleIDs = Set(initialEnabled.prefix(3))
        self.lastInteractionTimes["com.notchlet.calendar"] = Date()
        
        startNudgeMonitor()
    }
    
    private func startNudgeMonitor() {
        nudgeMonitorTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.checkNudgeStatus()
        }
        RunLoop.main.add(nudgeMonitorTimer!, forMode: .common)
    }
    
    private func checkNudgeStatus() {
        guard let nextEvent = CalendarViewModel.shared.nextEvent else { 
            lastNudgeInterval = nil
            return 
        }
        
        let now = Date()
        let diffSeconds = nextEvent.startDate.timeIntervalSince(now)
        let diffMinutes = Int(floor(diffSeconds / 60))
        
        // Trigger on: 60, 50, 40, 30, 20, 10, 5, 0 minutes
        let nudgePoints: Set<Int> = [60, 50, 40, 30, 20, 10, 5, 0]
        
        // Also handle ongoing meeting nudges (every 10m)
        let isOngoing = nextEvent.startDate <= now && (nextEvent.endDate ?? now) > now
        
        if isOngoing {
            let elapsedMinutes = Int(floor(now.timeIntervalSince(nextEvent.startDate) / 60))
            let currentOngoingInterval = elapsedMinutes / 10
            if lastNudgeInterval != currentOngoingInterval {
                lastNudgeInterval = currentOngoingInterval
                triggerNudge()
            }
        } else if diffMinutes <= 60 && diffMinutes >= 0 {
            if nudgePoints.contains(diffMinutes) && lastNudgeInterval != diffMinutes {
                lastNudgeInterval = diffMinutes
                triggerNudge()
            }
        } else {
            lastNudgeInterval = nil
        }
    }
    
    private func triggerNudge() {
        // Don't nudge if the notch is already expanded or we are already looking at calendar
        if isExpanded || activeExtensionID == "com.notchlet.calendar" { return }
        
        withAnimation(ThemeTokens.Spring.standard) {
            isNudgeActive = true
        }
    }
    
    func acknowledgeNudge() {
        if isNudgeActive {
            withAnimation(ThemeTokens.Spring.standard) {
                isNudgeActive = false
            }
        }
    }
    
    static func calculateNotchWidth() -> CGFloat {
        guard let screen = NSScreen.main else { return AppConfig.App.defaultNotchWidth }
        
        let screenWidth = screen.frame.width
        let leftAreaWidth = screen.auxiliaryTopLeftArea?.width ?? 0
        let rightAreaWidth = screen.auxiliaryTopRightArea?.width ?? 0
        
        // If auxiliary areas are reported, the gap between them is the notch
        if leftAreaWidth > 0 || rightAreaWidth > 0 {
            let notchWidth = screenWidth - leftAreaWidth - rightAreaWidth
            if notchWidth > 0 {
                return notchWidth
            }
        }
        
        // Fallback for non-notch screens (default aesthetic width)
        return AppConfig.App.defaultNotchWidth
    }
    
    static func calculateMenuBarHeight() -> CGFloat {
        guard let screen = NSScreen.main else { return AppConfig.App.defaultMenuBarHeight }
        
        let topInset = screen.safeAreaInsets.top
        if topInset > 0 {
            return topInset
        }
        
        // Fallback for non-notch screens (standard macOS menu bar height is 24pt)
        return AppConfig.App.fallbackMenuBarHeight
    }
}
