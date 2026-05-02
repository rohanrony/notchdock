import SwiftUI
import Combine
import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isExpanded: Bool = false
    @Published var activeExtensionID: String?
    @Published var enabledExtensionIDs: Set<String> = []
    @Published var extensionOrder: [String] = []
    @Published var homeViewModuleIDs: Set<String> = []
    @Published var registry: ExtensionRegistry
    @Published var purchaseManager: PurchaseManager
    @Published var detectedNotchWidth: CGFloat = 190
    @Published var detectedMenuBarHeight: CGFloat = 32 // Default fallback
    
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
        
        self.registry = registry
        self.purchaseManager = PurchaseManager()
        
        let firstID = registry.availableExtensions.first?.id
        self.activeExtensionID = firstID
        if let id = firstID {
            self.enabledExtensionIDs.insert(id)
        }
        // Enable all free modules by default for now
        for ext in registry.availableExtensions where !ext.isPremium {
            self.enabledExtensionIDs.insert(ext.id)
        }
        
        self.extensionOrder = registry.availableExtensions.map { $0.id }
        self.homeViewModuleIDs = Set(registry.availableExtensions.prefix(3).map { $0.id })
    }
    
    static func calculateNotchWidth() -> CGFloat {
        guard let screen = NSScreen.main else { return 190 }
        
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
        return 190
    }
    
    static func calculateMenuBarHeight() -> CGFloat {
        guard let screen = NSScreen.main else { return 32 }
        
        let topInset = screen.safeAreaInsets.top
        if topInset > 0 {
            return topInset
        }
        
        // Fallback for non-notch screens (standard macOS menu bar height is 24pt)
        return 24
    }
}
