import SwiftUI
import AppKit
import Combine

@main
struct NotchDockApp: App {
    @StateObject private var appState = AppState.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var notchPanel: NotchPanel?
    var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let appState = AppState.shared
        
        // Initialize the floating notch panel with the shared app state
        let panel = NotchPanel(appState: appState)
        self.notchPanel = panel
        
        // Observe isMinimized state to show/hide status item and panel
        appState.$isMinimized
            .receive(on: RunLoop.main)
            .sink { [weak self] isMinimized in
                self?.handleMinimizedState(isMinimized)
            }
            .store(in: &cancellables)
            
        // Initial setup
        handleMinimizedState(appState.isMinimized)
    }
    
    private func handleMinimizedState(_ isMinimized: Bool) {
        if isMinimized {
            // Hide notch panel
            notchPanel?.orderOut(nil)
            
            // Show status item if not already shown
            if statusItem == nil {
                setupStatusItem()
            }
        } else {
            // Show notch panel
            notchPanel?.makeKeyAndOrderFront(nil)
            
            // Remove status item
            statusItem = nil
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = createNotchImage()
            // Note: On macOS, setting a menu to the statusItem makes it respond to left clicks automatically
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Restore to Normal View", action: #selector(restoreFromMinimized), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit NotchDock", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func restoreFromMinimized() {
        AppState.shared.isMinimized = false
    }
    
    @objc func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func createNotchImage() -> NSImage {
        let size = NSSize(width: 20, height: 20) // Slightly larger for the border
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.labelColor.set()
            
            // 1. Draw Rounded Square Border (no fill)
            let borderPadding: CGFloat = 2
            let borderRect = rect.insetBy(dx: borderPadding, dy: borderPadding)
            let borderPath = NSBezierPath(roundedRect: borderRect, xRadius: 4, yRadius: 4)
            borderPath.lineWidth = 1.2
            borderPath.stroke()
            
            // 2. Draw Filled Notch inside (at the top center of the border)
            let notchWidth: CGFloat = 10
            let notchHeight: CGFloat = 4
            let x = (rect.width - notchWidth) / 2
            let y = borderRect.maxY - notchHeight - 1 // Aligned to the top of the border
            
            let radius: CGFloat = 1.5
            let notchPath = NSBezierPath()
            
            // Top-left
            notchPath.move(to: NSPoint(x: x, y: y + notchHeight))
            // Top-right
            notchPath.line(to: NSPoint(x: x + notchWidth, y: y + notchHeight))
            // Bottom-right curve
            notchPath.line(to: NSPoint(x: x + notchWidth, y: y + radius))
            notchPath.appendArc(withCenter: NSPoint(x: x + notchWidth - radius, y: y + radius), radius: radius, startAngle: 0, endAngle: 270, clockwise: true)
            // Bottom-left curve
            notchPath.line(to: NSPoint(x: x + radius, y: y))
            notchPath.appendArc(withCenter: NSPoint(x: x + radius, y: y + radius), radius: radius, startAngle: 270, endAngle: 180, clockwise: true)
            
            notchPath.close()
            notchPath.fill()
            
            return true
        }
        image.isTemplate = true
        return image
    }
}
