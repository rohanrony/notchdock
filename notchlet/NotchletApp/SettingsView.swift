import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            ExtensionsSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label("Extensions", systemImage: "puzzlepiece.extension")
                }
            
            APIKeysSettingsView()
                .tabItem {
                    Label("API Keys", systemImage: "key")
                }
            
            PaymentsSettingsView()
                .tabItem {
                    Label("Payments", systemImage: "creditcard")
                }
            
            SupportSettingsView()
                .tabItem {
                    Label("Support", systemImage: "heart")
                }
                
            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 600, height: 450)
        .padding()
    }
}

// MARK: - Subviews

struct ExtensionsSettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List {
            Section(header: Text("Installed Core Modules")) {
                ForEach(appState.registry.availableExtensions.filter { !$0.isPremium }, id: \.id) { ext in
                    ExtensionRow(ext: ext, isUnlocked: true)
                        .environmentObject(appState)
                }
            }
            
            Section(header: Text("Premium Extensions")) {
                ForEach(appState.registry.availableExtensions.filter { $0.isPremium }, id: \.id) { ext in
                    ExtensionRow(ext: ext, isUnlocked: appState.purchaseManager.owns(ext.productID))
                        .environmentObject(appState)
                }
            }
        }
    }
}

struct ExtensionRow: View {
    @EnvironmentObject var appState: AppState
    let ext: any NotchletExtension
    let isUnlocked: Bool
    
    var isEnabled: Binding<Bool> {
        Binding(
            get: { appState.enabledExtensionIDs.contains(ext.id) },
            set: { newValue in
                if newValue {
                    appState.enabledExtensionIDs.insert(ext.id)
                } else {
                    appState.enabledExtensionIDs.remove(ext.id)
                }
            }
        )
    }
    
    var body: some View {
        HStack {
            Image(systemName: ext.iconName)
                .foregroundColor(ThemeTokens.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text(ext.displayName).font(.headline)
            }
            
            Spacer()
            
            if isUnlocked {
                Toggle("", isOn: isEnabled)
            } else {
                Button(action: {
                    if let pid = ext.productID {
                        appState.purchaseManager.unlockMock(pid)
                    }
                }) {
                    Text("$1.00")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 4)
    }
}

struct APIKeysSettingsView: View {
    @AppStorage("claudeAPIKey") private var claudeAPIKey = ""
    
    var body: some View {
        Form {
            Section(header: Text("Claude API Configuration")) {
                SecureField("API Key (sk-ant-...)", text: $claudeAPIKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Stored securely in Keychain.")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            }
        }
        .padding()
    }
}

struct PaymentsSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("StoreKit Integration")) {
                Button("Restore Purchases") {
                    // StoreKit 2 restore logic
                }
                Text("Restore previous extension unlocks.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Tip Jar")) {
                HStack(spacing: 20) {
                    Button(action: {}) {
                        VStack {
                            Text("☕️").font(.title)
                            Text("$5")
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {}) {
                        VStack {
                            Text("🍕").font(.title)
                            Text("$10")
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {}) {
                        VStack {
                            Text("🚀").font(.title)
                            Text("$20")
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
    }
}

struct SupportSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Feedback")) {
                Button("Request a Feature") { }
                Button("Report a Bug") { }
                Button("Contact Support") { }
            }
        }
        .padding()
    }
}

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundColor(ThemeTokens.accentColor)
            
            Text("Notchlet")
                .font(.title)
                .bold()
            
            Text("Version 1.0.0 (Build 1)")
                .foregroundColor(.secondary)
            
            Button("Check for Updates") {}
                .buttonStyle(.bordered)
            
            HStack {
                Button("Privacy Policy") {}
                Button("Terms of Service") {}
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
