import SwiftUI
import Combine

// MARK: - Model

struct QuickAccessItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var heading: String
    var content: String
}

// MARK: - ViewModel

class QuickAccessViewModel: ObservableObject {
    static let shared = QuickAccessViewModel()
    
    @Published var items: [QuickAccessItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    private let storageKey = "com.notchdock.quickaccess.items"
    
    private init() {
        loadItems()
    }
    
    private func loadItems() {
        // 1. Try Keychain first
        if let data = KeychainHelper.shared.read(service: "com.notchdock.quickaccess", account: "items"),
           let decoded = try? JSONDecoder().decode([QuickAccessItem].self, from: data) {
            self.items = decoded
        } 
        // 2. Migration: Try UserDefaults if Keychain is empty
        else if let data = UserDefaults.standard.data(forKey: storageKey),
                let decoded = try? JSONDecoder().decode([QuickAccessItem].self, from: data) {
            self.items = decoded
            // Securely save to Keychain and remove from UserDefaults
            saveItems()
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
        else {
            // Default initial items
            self.items = [
                QuickAccessItem(heading: "My Prompt", content: "Please review the following text for clarity, tone, and grammatical accuracy..."),
                QuickAccessItem(heading: "ID#", content: "#00000000"),
                QuickAccessItem(heading: "Rohan's email", content: "hello@notchdock.app"),
                QuickAccessItem(heading: "SSH", content: "ssh root@192.168.1.1"),
                QuickAccessItem(heading: "Edit this", content: "Copy this → (Hover to see icons)")
            ]
        }
        
        // Ensure guide shown flag is set
        let guideKey = "com.notchdock.quickaccess.guideShown.v1"
        if !UserDefaults.standard.bool(forKey: guideKey) {
            UserDefaults.standard.set(true, forKey: guideKey)
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            KeychainHelper.shared.save(encoded, service: "com.notchdock.quickaccess", account: "items")
        }
    }
    
    func addItem(heading: String = "", content: String = "") {
        withAnimation(ThemeTokens.Spring.standard) {
            items.append(QuickAccessItem(heading: heading, content: content))
        }
    }
    
    func updateItem(_ item: QuickAccessItem, heading: String? = nil, content: String? = nil) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if let heading = heading { items[index].heading = heading }
            if let content = content { items[index].content = content }
        }
    }
    
    func deleteItem(_ item: QuickAccessItem) {
        withAnimation(ThemeTokens.Spring.standard) {
            items.removeAll(where: { $0.id == item.id })
        }
    }
    
    func moveItem(fromOffsets source: IndexSet, toOffset destination: Int) {
        withAnimation(ThemeTokens.Spring.standard) {
            items.move(fromOffsets: source, toOffset: destination)
        }
    }
}

// MARK: - UI Components

struct QuickAccessRow: View {
    @ObservedObject var viewModel = QuickAccessViewModel.shared
    let item: QuickAccessItem
    
    @State private var isHovered = false
    @State private var editingHeading: String
    @State private var editingContent: String
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case heading
        case content
    }
    
    init(item: QuickAccessItem) {
        self.item = item
        _editingHeading = State(initialValue: item.heading)
        _editingContent = State(initialValue: item.content)
    }
    
    var body: some View {
        GeometryReader { rowGeo in
            HStack(alignment: .center, spacing: 0) {
                // Heading (1/3 width) - Styled as a Label
                ZStack(alignment: .leading) {
                    if editingHeading.isEmpty && focusedField != .heading {
                        Text("Label...")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(ThemeTokens.secondaryText.opacity(0.3))
                            .allowsHitTesting(false)
                    }
                    
                    TextField("", text: $editingHeading, onCommit: {
                        viewModel.updateItem(item, heading: editingHeading)
                    })
                    .textFieldStyle(.plain)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeTokens.accentColor)
                    .focused($focusedField, equals: .heading)
                    .autocorrectionDisabled(true)
                    .textContentType(.none)
                }
                .padding(.horizontal, 8)
                .frame(minWidth: rowGeo.size.width / 3.2, maxWidth: rowGeo.size.width / 3.2, maxHeight: .infinity, alignment: .leading)
                .background(ThemeTokens.accentColor.opacity(0.1))
                .cornerRadius(3)
                
                Spacer(minLength: 12)
                
                // Content (Remaining width)
                ZStack(alignment: .leading) {
                    if editingContent.isEmpty && focusedField != .content {
                        Text("Content...")
                            .font(.system(size: 13))
                            .foregroundColor(ThemeTokens.secondaryText.opacity(0.3))
                            .allowsHitTesting(false)
                    }
                    
                    TextField("", text: $editingContent, onCommit: {
                        viewModel.updateItem(item, content: editingContent)
                    })
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(ThemeTokens.secondaryText)
                    .focused($focusedField, equals: .content)
                    .autocorrectionDisabled(true)
                    .textContentType(.none)
                }
                .frame(maxHeight: .infinity)
                
                Spacer()
                
                if isHovered {
                    HStack(spacing: 8) {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(editingContent, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeTokens.secondaryText.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                        .help("Copy content")
                        
                        Button(action: { viewModel.deleteItem(item) }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 13))
                                .foregroundColor(ThemeTokens.secondaryText.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.opacity)
                }
            }
        }
        .frame(height: 26)
        .padding(.horizontal, 4)
        .background(Color.white.opacity(isHovered ? 0.03 : 0))
        .cornerRadius(6)
        .onHover { h in withAnimation(.easeInOut(duration: 0.1)) { isHovered = h } }
        .onChange(of: editingHeading) { oldValue, newValue in viewModel.updateItem(item, heading: newValue) }
        .onChange(of: editingContent) { oldValue, newValue in viewModel.updateItem(item, content: newValue) }
        .onChange(of: focusedField) { oldValue, newValue in
            // If we lost focus and both fields are empty, remove the row
            if newValue == nil && editingHeading.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && editingContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.deleteItem(item)
            }
        }
    }
}

struct AddQuickAccessRow: View {
    @ObservedObject var viewModel = QuickAccessViewModel.shared
    
    var body: some View {
        Button(action: { viewModel.addItem() }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 14))
                Text("Add Item to Quick Access Clipboard")
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            .foregroundColor(ThemeTokens.secondaryText.opacity(0.5))
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Main Views

struct QuickAccessExpandedView: View {
    @ObservedObject var viewModel = QuickAccessViewModel.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(viewModel.items) { item in
                        QuickAccessRow(item: item)
                    }
                    
                    AddQuickAccessRow()
                        .padding(.top, 4)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
            }
            .frame(minWidth: 320, maxHeight: 400)
        }
        .accessibilityIdentifier("quickaccess_view")
    }
}

struct QuickAccessCompactView: View {
    @ObservedObject var viewModel = QuickAccessViewModel.shared
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ThemeTokens.primaryText)
            
            if !viewModel.items.isEmpty {
                Text("\(viewModel.items.count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(ThemeTokens.secondaryText.opacity(0.5))
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Module Definition

struct QuickAccessModule: NotchDockExtension {
    var id: String = "com.notchdock.quickaccess"
    var displayName: String = "Quick Access"
    var iconName: String = "doc.on.clipboard"
    
    var isPremium: Bool = false
    var productID: String? = nil
    var hasRequiredPermissions: Bool = true
    var hasCompactView: Bool = false
    
    var compactView: AnyView {
        AnyView(QuickAccessCompactView())
    }
    
    var expandedView: AnyView {
        AnyView(QuickAccessExpandedView())
    }
    
    var settingsView: AnyView {
        AnyView(
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Quick Access Settings")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeTokens.primaryText)
                    
                    SectionCard(title: "Features", subtitle: "Handy tools for quick data access.") {
                        VStack(spacing: 0) {
                            SettingsRow("Instant Retrieval", icon: "doc.on.clipboard") {
                                Text("Enabled").font(.system(size: 12)).foregroundColor(.secondary)
                            }
                            Divider().padding(.leading, 48)
                            SettingsRow("One-Tap Copy", icon: "doc.on.doc") {
                                Text("Enabled").font(.system(size: 12)).foregroundColor(.secondary)
                            }
                        }
                    }
                    
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 10))
                        Text("Strictly Local. Strictly Private.")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(ThemeTokens.accentColor)
                    
                    Text("Everything you save in Quick Access stays in your local Keychain and application sandbox. NotchDock never syncs or transmits your snippets to any external server.")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
                .padding(.horizontal, 4)
            }
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        )
    }
}
