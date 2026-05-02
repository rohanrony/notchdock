import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSection: SettingsSection? = .general
    
    enum SettingsSection: Hashable {
        case general
        case module(String)
        case extensions
        case support
        case about
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Custom Sidebar Header with Toggle
                HStack {
                    Spacer()
                    Button(action: {
                        #if os(macOS)
                        NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
                        #endif
                    }) {
                        Image(systemName: "sidebar.left")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                List(selection: $selectedSection) {
                    NavigationLink(value: SettingsSection.general) {
                        Label("General", systemImage: "gear")
                    }
                    
                    Section("Modules") {
                        ForEach(appState.registry.availableExtensions.filter { appState.enabledExtensionIDs.contains($0.id) }, id: \.id) { ext in
                            NavigationLink(value: SettingsSection.module(ext.id)) {
                                Label(ext.displayName, systemImage: ext.iconName)
                            }
                        }
                    }
                    
                    Section("Marketplace") {
                        NavigationLink(value: SettingsSection.extensions) {
                            Label("Extensions", systemImage: "puzzlepiece.extension")
                        }
                    }
                    
                    Section("Help") {
                        NavigationLink(value: SettingsSection.support) {
                            Label("Support", systemImage: "questionmark.circle")
                        }
                        NavigationLink(value: SettingsSection.about) {
                            Label("About", systemImage: "info.circle")
                        }
                    }
                }
                .listStyle(.sidebar)
            }
            .navigationSplitViewColumnWidth(min: 150, ideal: 160, max: 180)
        } detail: {
            Group {
                if let section = selectedSection {
                    switch section {
                    case .general:
                        GeneralSettingsView()
                    case .module(let id):
                        if let ext = appState.registry.availableExtensions.first(where: { $0.id == id }) {
                            ext.settingsView
                        }
                    case .extensions:
                        ExtensionsSettingsView()
                    case .support:
                        SupportSettingsView()
                    case .about:
                        AboutSettingsView()
                    }
                } else {
                    Text("Select a category")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(width: 525, height: 420)
        .toolbar(removing: .sidebarToggle)
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("General")
                    .font(.title2)
                    .bold()
                
                // 1. Module Toggles (Enable/Disable)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Modules")
                        .font(.headline)
                    Text("Enable or disable modules in the notch.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        ForEach(appState.registry.availableExtensions.filter { !$0.isPremium }, id: \.id) { ext in
                            Toggle(isOn: Binding(
                                get: { appState.enabledExtensionIDs.contains(ext.id) },
                                set: { val in
                                    if val {
                                        appState.enabledExtensionIDs.insert(ext.id)
                                        if !appState.extensionOrder.contains(ext.id) {
                                            appState.extensionOrder.append(ext.id)
                                        }
                                    } else {
                                        appState.enabledExtensionIDs.remove(ext.id)
                                        appState.homeViewModuleIDs.remove(ext.id) // Also remove from home view
                                        if appState.activeExtensionID == ext.id {
                                            appState.activeExtensionID = appState.enabledExtensionIDs.first
                                        }
                                    }
                                }
                            )) {
                                Label(ext.displayName, systemImage: ext.iconName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .toggleStyle(.checkbox)
                        }
                    }
                    .padding(10)
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(8)
                }
                
                Divider()

                // 2. Module Ordering (Only show enabled ones)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Module Order")
                        .font(.headline)
                    Text("Drag to reorder how they appear in the switcher.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    List {
                        ForEach(appState.extensionOrder.filter { appState.enabledExtensionIDs.contains($0) }, id: \.self) { id in
                            if let ext = appState.registry.availableExtensions.first(where: { $0.id == id }) {
                                HStack {
                                    Image(systemName: ext.iconName)
                                        .foregroundColor(ThemeTokens.accentColor)
                                        .frame(width: 20)
                                    Text(ext.displayName)
                                    Spacer()
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onMove { indices, newOffset in
                            // Need to map the filtered indices back to the original extensionOrder indices
                            var currentOrder = appState.extensionOrder
                            let enabledIDs = currentOrder.filter { appState.enabledExtensionIDs.contains($0) }
                            let movedIDs = indices.map { enabledIDs[$0] }
                            
                            // Remove moved items from original order
                            currentOrder.removeAll(where: { movedIDs.contains($0) })
                            
                            // Find insertion point in original order based on newOffset in filtered list
                            var insertIndex = 0
                            if newOffset < enabledIDs.count {
                                let targetID = enabledIDs[newOffset]
                                insertIndex = currentOrder.firstIndex(of: targetID) ?? currentOrder.count
                            } else {
                                insertIndex = currentOrder.count
                            }
                            
                            currentOrder.insert(contentsOf: movedIDs, at: insertIndex)
                            appState.extensionOrder = currentOrder
                        }
                    }
                    .frame(height: 140)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2)))
                }
                
                Divider()

                // 3. Home View
                VStack(alignment: .leading, spacing: 12) {
                    Text("Home View")
                        .font(.headline)
                    Text("Select widgets for the Home View.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(appState.registry.availableExtensions.filter { appState.enabledExtensionIDs.contains($0.id) }, id: \.id) { ext in
                            Toggle(ext.displayName, isOn: Binding(
                                get: { appState.homeViewModuleIDs.contains(ext.id) },
                                set: { val in
                                    if val {
                                        if appState.homeViewModuleIDs.count < AppConfig.App.homeViewLimit {
                                            appState.homeViewModuleIDs.insert(ext.id)
                                        }
                                    } else {
                                        appState.homeViewModuleIDs.remove(ext.id)
                                    }
                                }
                            ))
                            .toggleStyle(.checkbox)
                            .disabled(!appState.homeViewModuleIDs.contains(ext.id) && appState.homeViewModuleIDs.count >= AppConfig.App.homeViewLimit)
                        }
                        
                        if appState.homeViewModuleIDs.count >= AppConfig.App.homeViewLimit {
                            Text("Limit of \(AppConfig.App.homeViewLimit) widgets reached.")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Divider()

                // 4. Startup
                VStack(alignment: .leading, spacing: 12) {
                    Text("System")
                        .font(.headline)
                    Toggle("Launch at login", isOn: $launchAtLogin)
                        .toggleStyle(.checkbox)
                        .onChange(of: launchAtLogin) { _, enabled in
                            Task {
                                do {
                                    if enabled {
                                        try SMAppService.mainApp.register()
                                    } else {
                                        try await SMAppService.mainApp.unregister()
                                    }
                                } catch {
                                    try? await Task.sleep(nanoseconds: 100_000_000)
                                    await MainActor.run {
                                        launchAtLogin = SMAppService.mainApp.status == .enabled
                                    }
                                }
                            }
                        }
                }
            }
            .padding(24)
        }
    }
}

// MARK: - About Page
struct AboutSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("About")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 64))
                        .foregroundColor(ThemeTokens.accentColor)
                        .padding(.bottom, 8)
                    
                    Text("Notchlet")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    Text("Created by")
                        .font(.headline)
                    
                    VStack(spacing: 4) {
                        Text("Rohan Roy")
                            .font(.title3)
                    }
                    
                    Button(action: {
                        if let url = URL(string: "mailto:rr.viberdev@gmail.com") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Label("rr.viberdev@gmail.com", systemImage: "envelope")
                    }
                    .buttonStyle(.link)
                }
                
                Divider()
                    .frame(width: 200)
                
                HStack(spacing: 20) {
                    Button("Check for Updates") {}
                        .buttonStyle(.bordered)
                    
                    Button("Website") {}
                        .buttonStyle(.bordered)
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Button("Privacy Policy") {}
                        Text("•")
                        Button("Terms of Service") {}
                    }
                    .font(.caption)
                    .buttonStyle(.link)
                    
                    Text("© 2026 Notchlet Team. All rights reserved.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Support Settings (Reuse existing)
struct SupportSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Support")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 8)
                
                Form {
                    Section(header: Text("Feedback")) {
                        Button("Request a Feature") { }
                        Button("Report a Bug") { }
                        Button("Contact Support") { }
                    }
                }
            }
            .padding(.top, 24)
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Extensions Marketplace
struct ExtensionsSettingsView: View {
    let websiteURL = "https://notchlet.app/extensions"
    
    struct PremiumExtension {
        let name: String
        let icon: String
        let description: String
        let price: String
    }
    
    let premiumExtensions: [PremiumExtension] = [
        PremiumExtension(name: "Claude AI", icon: "sparkles", description: "Ask Claude anything, directly from your notch.", price: "$1.99"),
        PremiumExtension(name: "Focus Mode", icon: "timer.circle", description: "Block distractions and enter deep work sessions.", price: "$0.99"),
        PremiumExtension(name: "System Monitor", icon: "cpu", description: "Live CPU, RAM, and network stats in your notch.", price: "$0.99"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Extensions")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .center, spacing: 20) {
                        Image(systemName: "puzzlepiece.extension")
                            .font(.system(size: 48))
                            .foregroundColor(ThemeTokens.accentColor)
                            .padding(.top, 40)
                        
                        Text("Premium Extensions")
                            .font(.headline)
                        
                        Text("(Coming soon...)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("New modules like Focus Mode, System Monitor, and AI enhancements are currently in development.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 24)
                .padding(.horizontal)
            }
            
            Divider()
            
            HStack {
                Text("Browse and purchase extensions on our website.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Visit Website") {
                    if let url = URL(string: websiteURL) {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
