import SwiftUI
import AppKit

@main
struct NotchletApp: App {
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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the floating notch panel with the shared app state
        let panel = NotchPanel(appState: AppState.shared)
        self.notchPanel = panel
        panel.makeKeyAndOrderFront(nil)
    }
}
