import SwiftUI
import AppKit

class NotchPanel: NSPanel {
    init(appState: AppState) {
        // Standard notch size is approximately 200x32, we make the panel slightly larger to accommodate expansion
        let screenRect = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let panelWidth: CGFloat = 800 // Wider to support the new left/right layout
        let panelHeight: CGFloat = 400 // Taller for expanded modules
        
        // Position at top center
        let rect = NSRect(
            x: screenRect.midX - (panelWidth / 2),
            y: screenRect.maxY - panelHeight,
            width: panelWidth,
            height: panelHeight
        )
        
        super.init(
            contentRect: rect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.isFloatingPanel = true
        self.level = .mainMenu + 1 // Float above menu bar
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        
        // Host the SwiftUI View with the SHARED appState
        let hostingView = NSHostingView(rootView: IslandView().environmentObject(appState))
        self.contentView = hostingView
    }
    
    override var canBecomeKey: Bool {
        return true // Allow interaction
    }
}
