import SwiftUI
import Combine
import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isExpanded: Bool = false
    @Published var isPinned: Bool = false
    @Published var activeExtensionID: String?
    @Published var enabledExtensionIDs: Set<String> = []
    @Published var extensionOrder: [String] = []
    @Published var homeViewModuleIDs: Set<String> = []
    @Published var registry: ExtensionRegistry
    @Published var purchaseManager: PurchaseManager
    @Published var detectedNotchWidth: CGFloat = AppConfig.App.defaultNotchWidth
    @Published var detectedMenuBarHeight: CGFloat = AppConfig.App.defaultMenuBarHeight // Default fallback
    
    init() {
        // Detect actual notch width and height if available
        self.detectedNotchWidth = AppState.calculateNotchWidth()
        self.detectedMenuBarHeight = AppState.calculateMenuBarHeight()
        let registry = ExtensionRegistry()
        registry.register(CalendarModule())
        registry.register(ClipboardModule())
        registry.register(TimerModule())
        registry.register(MusicModule())
        registry.register(ClaudeModule())
        registry.register(ToDoModule())
        
        self.registry = registry
        self.purchaseManager = PurchaseManager()
        
        let defaultOrder = [
            "com.notchlet.calendar",
            "com.notchlet.timer",
            "com.notchlet.music",
            "com.notchlet.clipboard",
            "com.notchlet.claude",
            "com.notchlet.todo"
        ]
        
        let initialEnabled = [
            "com.notchlet.calendar",
            "com.notchlet.timer",
            "com.notchlet.music",
            "com.notchlet.clipboard",
            "com.notchlet.todo"
        ]
        
        self.extensionOrder = defaultOrder
        self.enabledExtensionIDs = Set(initialEnabled)
        self.activeExtensionID = "com.notchlet.calendar"
        self.homeViewModuleIDs = Set(initialEnabled.prefix(3))
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
