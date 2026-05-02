import SwiftUI
import Combine
import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isExpanded: Bool = false
    @Published var activeExtensionID: String?
    @Published var enabledExtensionIDs: Set<String> = []
    @Published var registry: ExtensionRegistry
    @Published var purchaseManager: PurchaseManager
    
    init() {
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
    }
}
