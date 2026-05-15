import SwiftUI
import ServiceManagement
import AppKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSection: SettingsSection? = .general
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    enum SettingsSection: Hashable {
        case general
        case module(String)
        case extensions
        case support
        case about
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack(spacing: 0) {
                // Custom Sidebar Header
                HStack {
                    Text("notchdock")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeTokens.primaryText)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                VStack(spacing: 4) {
                    SidebarItem(title: "General", icon: "gearshape.fill", section: .general, selectedSection: $selectedSection)
                    SidebarItem(title: "Extensions", icon: "puzzlepiece.extension.fill", section: .extensions, selectedSection: $selectedSection)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Modules")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary.opacity(0.6))
                            .padding(.leading, 12)
                            .padding(.top, 12)
                        
                        ForEach(appState.registry.availableExtensions.filter { appState.enabledExtensionIDs.contains($0.id) }, id: \.id) { ext in
                            SidebarItem(title: ext.displayName, icon: ext.iconName, section: .module(ext.id), selectedSection: $selectedSection)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Help")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary.opacity(0.6))
                            .padding(.leading, 12)
                            .padding(.top, 12)
                        
                        SidebarItem(title: "Support", icon: "questionmark.circle.fill", section: .support, selectedSection: $selectedSection)
                        SidebarItem(title: "About", icon: "info.circle.fill", section: .about, selectedSection: $selectedSection)
                    }
                }
                .padding(.horizontal, 8)
                
                Spacer()
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
            .background(ThemeTokens.sidebarBackground)
        } detail: {
            ZStack {
                ThemeTokens.backgroundColor.ignoresSafeArea()
                
                NavigationStack {
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
                            VStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 48))
                                    .foregroundColor(ThemeTokens.accentColor.opacity(0.3))
                                Text("Select a category to get started")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ThemeTokens.backgroundColor)
                    .toolbar(.hidden)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(width: 720, height: 520)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { notification in
            if let window = notification.object as? NSWindow, window.isMiniaturized {
                window.deminiaturize(nil)
            }
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}


// MARK: - Sidebar Item
struct SidebarItem: View {
    let title: String
    let icon: String
    let section: SettingsView.SettingsSection
    @Binding var selectedSection: SettingsView.SettingsSection?
    
    var isSelected: Bool {
        selectedSection == section
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(isSelected ? .white : ThemeTokens.accentColor)
                .font(.system(size: 14))
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : ThemeTokens.primaryText)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? ThemeTokens.selectedSidebarItem : Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedSection = section
            }
        }
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("General")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeTokens.primaryText)
                
                // 1. Modules Toggle
                SectionCard(title: "Modules", subtitle: "Enable or disable modules in the notch.") {
                    VStack(spacing: 0) {
                        let nonPremiumExtensions = appState.registry.availableExtensions.filter { !$0.isPremium }
                        ForEach(Array(nonPremiumExtensions.enumerated()), id: \.element.id) { index, ext in
                            SettingsRow(ext.displayName, icon: ext.iconName) {
                                Toggle("", isOn: Binding(
                                    get: { appState.enabledExtensionIDs.contains(ext.id) },
                                    set: { val in
                                        if val {
                                            appState.enabledExtensionIDs.insert(ext.id)
                                            if !appState.extensionOrder.contains(ext.id) {
                                                appState.extensionOrder.append(ext.id)
                                            }
                                        } else {
                                            appState.enabledExtensionIDs.remove(ext.id)
                                            appState.homeViewModuleIDs.remove(ext.id)
                                            if appState.activeExtensionID == ext.id {
                                                appState.activeExtensionID = appState.enabledExtensionIDs.first
                                            }
                                        }
                                    }
                                ))
                                .toggleStyle(.switch)
                                .scaleEffect(0.8)
                            }
                            
                            if index < nonPremiumExtensions.count - 1 {
                                Divider().padding(.leading, 48)
                            }
                        }
                    }
                }
                
                // 2. Module Ordering
                SectionCard(title: "Module Order", subtitle: "Drag to reorder how they appear in the switcher.") {
                    List {
                        ForEach(appState.extensionOrder.filter { appState.enabledExtensionIDs.contains($0) }, id: \.self) { id in
                            if let ext = appState.registry.availableExtensions.first(where: { $0.id == id }) {
                                HStack {
                                    Image(systemName: ext.iconName)
                                        .foregroundColor(ThemeTokens.accentColor)
                                        .frame(width: 24)
                                    Text(ext.displayName)
                                        .font(.system(size: 13))
                                    Spacer()
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundColor(.secondary.opacity(0.5))
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 4)
                            }
                        }
                        .onMove { indices, newOffset in
                            var currentOrder = appState.extensionOrder
                            let enabledIDs = currentOrder.filter { appState.enabledExtensionIDs.contains($0) }
                            let movedIDs = indices.map { enabledIDs[$0] }
                            currentOrder.removeAll(where: { movedIDs.contains($0) })
                            
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
                    .listStyle(.plain)
                    .frame(height: 180)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                
                // 3. System
                SectionCard(title: "System") {
                    SettingsRow("Launch at login", icon: "arrow.up.right.square") {
                        Toggle("", isOn: $launchAtLogin)
                            .toggleStyle(.switch)
                            .scaleEffect(0.8)
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
                    
                    Divider().padding(.leading, 48)
                    
                    SettingsRow("Minimize to Icon View", icon: "square.dashed") {
                        Toggle("", isOn: $appState.isMinimized)
                            .toggleStyle(.switch)
                            .scaleEffect(0.8)
                    }
                    
                    Divider().padding(.leading, 48)
                    
                    SettingsRow("Quit NotchDock", icon: "power") {
                        Button(role: .destructive) {
                            NSApplication.shared.terminate(nil)
                        } label: {
                            Text("Quit")
                                .font(.system(size: 11, weight: .semibold))
                                .padding(.horizontal, 8)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .controlSize(.small)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - About Page
struct AboutSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(ThemeTokens.accentColor.gradient)
                            .frame(width: 100, height: 100)
                            .shadow(color: ThemeTokens.accentColor.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 4) {
                        Text("NotchDock")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(ThemeTokens.primaryText)
                        
                        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                SectionCard {
                    VStack(spacing: 0) {
                        SettingsRow("Check for Updates", icon: "arrow.clockwise") {
                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                        }
                        Divider().padding(.leading, 48)
                        SettingsRow("Website", icon: "globe") {
                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                        }
                        Divider().padding(.leading, 48)
                        Button(action: {
                            if let url = Bundle.main.url(forResource: "10-security-checks", withExtension: "md", subdirectory: "docs") {
                                NSWorkspace.shared.open(url)
                            } else {
                                // Fallback to GitHub or project site if local file not in bundle
                                if let url = URL(string: "https://github.com/rohanrony/notchdock/blob/main/notchdock/docs/10-security-checks.md") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                        }) {
                            SettingsRow("Privacy Policy", icon: "shield.lefthalf.filled") {
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 40)
                
                VStack(spacing: 8) {
                    Text("Handcrafted by Rohan Roy")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(ThemeTokens.secondaryText)
                    
                    Text("© 2026 NotchDock Team. All rights reserved.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Support Settings
struct SupportSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Support")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeTokens.primaryText)
                
                SectionCard(title: "Feedback & Issues") {
                    VStack(spacing: 0) {
                        SettingsRow("Request a Feature", icon: "lightbulb.fill") {
                            Image(systemName: "arrow.up.right").font(.caption).foregroundColor(.secondary)
                        }
                        Divider().padding(.leading, 48)
                        SettingsRow("Report a Bug", icon: "ant.fill") {
                            Image(systemName: "arrow.up.right").font(.caption).foregroundColor(.secondary)
                        }
                        Divider().padding(.leading, 48)
                        SettingsRow("Contact Support", icon: "envelope.fill") {
                            Image(systemName: "arrow.up.right").font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                
                SectionCard(title: "Documentation") {
                    SettingsRow("User Guide", icon: "book.fill") {
                        Image(systemName: "arrow.up.right").font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }
}
// MARK: - Extensions Page
struct ExtensionsSettingsView: View {
    let roadmap = [
        ("Slack", "bubble.left.and.exclamationmark.bubble.right.fill"),
        ("Messages", "message.fill"),
        ("WhatsApp", "phone.circle.fill"),
        ("Mail", "envelope.fill"),
        ("Airdrop / Files Tray", "square.and.arrow.up.fill"),
        ("Live Camera", "video.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Extensions")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeTokens.primaryText)
                    
                    Text("Expanding the Island — New capabilities are currently being handcrafted in the kitchen. Stay tuned for fresh updates arriving soon.")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeTokens.secondaryText)
                        .lineSpacing(4)
                }
                
                SectionCard(title: "Roadmap", subtitle: "What we're working on next.") {
                    VStack(spacing: 0) {
                        ForEach(Array(roadmap.enumerated()), id: \.offset) { index, item in
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(ThemeTokens.accentColor.opacity(0.1))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: item.1)
                                        .font(.system(size: 14))
                                        .foregroundColor(ThemeTokens.accentColor)
                                }
                                
                                Text(item.0)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(ThemeTokens.primaryText)
                                
                                Spacer()
                                
                                Text("Planned")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(6)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            if index < roadmap.count - 1 {
                                Divider().padding(.leading, 64)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }
}
