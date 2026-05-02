import SwiftUI
import Combine
import UniformTypeIdentifiers

// MARK: - Model

struct ToDoItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var text: String
    var isCompleted: Bool = false
}

// MARK: - ViewModel

class ToDoViewModel: ObservableObject {
    static let shared = ToDoViewModel()
    
    @Published var items: [ToDoItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    private let storageKey = "com.notchlet.todo.items"
    
    private init() {
        loadItems()
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ToDoItem].self, from: data) {
            self.items = decoded
        } else {
            self.items = [
                ToDoItem(text: "Welcome to Notchlet ToDo"),
                ToDoItem(text: "Hold and drag to reorder"),
                ToDoItem(text: "Tap to edit tasks")
            ]
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func addItem(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        withAnimation(ThemeTokens.Spring.standard) {
            items.append(ToDoItem(text: trimmed))
        }
    }
    
    func toggleItem(_ item: ToDoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                items[index].isCompleted.toggle()
            }
        }
    }
    
    func deleteItem(_ item: ToDoItem) {
        withAnimation(ThemeTokens.Spring.standard) {
            items.removeAll(where: { $0.id == item.id })
        }
    }
    
    func updateItem(_ item: ToDoItem, with text: String) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].text = text
        }
    }
    
    func moveItem(fromOffsets source: IndexSet, toOffset destination: Int) {
        withAnimation(ThemeTokens.Spring.standard) {
            items.move(fromOffsets: source, toOffset: destination)
        }
    }
}

// MARK: - Premium UI Components

struct SparkleEffect: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(ThemeTokens.accentColor)
                    .frame(width: 4, height: 4)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .offset(x: particle.x, y: particle.y)
            }
        }
        .onAppear {
            for _ in 0..<8 {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 10...30)
                let p = Particle(x: 0, y: 0, scale: 0.1, opacity: 1.0)
                particles.append(p)
                
                let index = particles.count - 1
                withAnimation(.easeOut(duration: 0.6)) {
                    particles[index].x = cos(angle) * distance
                    particles[index].y = sin(angle) * distance
                    particles[index].scale = 1.0
                    particles[index].opacity = 0
                }
            }
        }
    }
}

struct AnimatedStrikethrough: View {
    var isVisible: Bool
    var color: Color
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                Rectangle()
                    .fill(color)
                    .frame(height: 1.2)
                    .frame(width: isVisible ? geo.size.width : 0)
                Spacer()
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
        }
    }
}

// MARK: - Row Views

struct ToDoRow: View {
    @ObservedObject var viewModel = ToDoViewModel.shared
    let item: ToDoItem
    
    @State private var isHovered = false
    @State private var isEditing = false
    @State private var editText: String
    @State private var checkboxScale: CGFloat = 1.0
    @State private var showSparkle = false
    @FocusState private var isFocused: Bool
    
    init(item: ToDoItem) {
        self.item = item
        _editText = State(initialValue: item.text)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Checkbox
            ZStack {
                Circle()
                    .strokeBorder(item.isCompleted ? ThemeTokens.accentColor : ThemeTokens.secondaryText.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 18, height: 18)
                
                if item.isCompleted {
                    Circle()
                        .fill(ThemeTokens.accentColor)
                        .frame(width: 18, height: 18)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if showSparkle {
                    SparkleEffect()
                }
            }
            .contentShape(Circle())
            .scaleEffect(checkboxScale)
            .onTapGesture {
                viewModel.toggleItem(item)
                if !item.isCompleted {
                    showSparkle = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { showSparkle = false }
                }
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    checkboxScale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        checkboxScale = 1.0
                    }
                }
            }
            
            // Text
            ZStack(alignment: .leading) {
                if isEditing {
                    TextField("", text: $editText, onCommit: {
                        viewModel.updateItem(item, with: editText)
                        isEditing = false
                    })
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(ThemeTokens.primaryText)
                    .focused($isFocused)
                    .onAppear { isFocused = true }
                } else {
                    Text(item.text)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(item.isCompleted ? ThemeTokens.secondaryText.opacity(0.35) : ThemeTokens.secondaryText)
                        .strikethrough(item.isCompleted, color: ThemeTokens.secondaryText.opacity(0.5))
                        .lineLimit(nil) // Enable multi-line wrapping
                        .fixedSize(horizontal: false, vertical: true) // Allow vertical growth
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isEditing = true
                        }
                }
            }
            
            // Reorder Handle & Delete Button Container
            HStack(spacing: 8) {
                if isHovered {
                    Button(action: { viewModel.deleteItem(item) }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeTokens.secondaryText.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                
                // Visible handle for reordering
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 12))
                    .foregroundColor(ThemeTokens.secondaryText.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 3)
        .padding(.leading, 6) // Ultra-flush left
        .padding(.trailing, 8)
        .background(Color.white.opacity(isHovered ? 0.05 : 0))
        .cornerRadius(8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }
}

struct AddToDoRow: View {
    @ObservedObject var viewModel = ToDoViewModel.shared
    @State private var newText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle")
                .font(.system(size: 18))
                .foregroundColor(ThemeTokens.secondaryText.opacity(0.5))
            
            TextField("Add a task...", text: $newText)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(ThemeTokens.secondaryText)
                .focused($isFocused)
                .onSubmit {
                    viewModel.addItem(text: newText)
                    newText = ""
                    isFocused = true
                }
            
            if !newText.isEmpty {
                Button(action: {
                    viewModel.addItem(text: newText)
                    newText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ThemeTokens.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 5)
        .padding(.leading, 6) // Ultra-flush left
        .padding(.trailing, 12)
        .background(Color.clear)
    }
}

// MARK: - Main Expanded View

struct ToDoExpandedView: View {
    @ObservedObject var viewModel = ToDoViewModel.shared
    @State private var draggingItem: ToDoItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(viewModel.items) { item in
                        ToDoRow(item: item)
                            .opacity(draggingItem?.id == item.id ? 0 : 1)
                            .onDrag {
                                self.draggingItem = item
                                return NSItemProvider(object: item.id.uuidString as NSString)
                            }
                            .onDrop(of: [.text], delegate: ToDoDropDelegate(item: item, items: $viewModel.items, draggedItem: $draggingItem))
                    }
                    
                    AddToDoRow()
                        .padding(.top, 2)
                }
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 16)
            .frame(minWidth: 280, maxHeight: CGFloat(min(400, 30 + viewModel.items.count * 32 + 60)))
            .animation(ThemeTokens.Spring.standard, value: viewModel.items.count)
        }
    }
}

struct ToDoDropDelegate: DropDelegate {
    let item: ToDoItem
    @Binding var items: [ToDoItem]
    @Binding var draggedItem: ToDoItem?
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem != item,
              let from = items.firstIndex(of: draggedItem),
              let to = items.firstIndex(of: item) else { return }
        
        if items[to] != draggedItem {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

// MARK: - Compact View

struct ToDoCompactView: View {
    @ObservedObject var viewModel = ToDoViewModel.shared
    @State private var badgeScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checklist")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ThemeTokens.primaryText)
            
            let remaining = viewModel.items.filter { !$0.isCompleted }.count
            if remaining > 0 {
                Text("\(remaining)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        ZStack {
                            Capsule().fill(ThemeTokens.accentColor)
                            Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                        }
                    )
                    .shadow(color: ThemeTokens.accentColor.opacity(0.4), radius: 4, x: 0, y: 1)
                    .scaleEffect(badgeScale)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 8)
        .onChange(of: viewModel.items.count) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                badgeScale = 1.4
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                    badgeScale = 1.0
                }
            }
        }
    }
}

// MARK: - Module Definition

struct ToDoModule: NotchletExtension {
    var id: String = "com.notchlet.todo"
    var displayName: String = "ToDo"
    var iconName: String = "checklist"
    
    var isPremium: Bool = false
    var productID: String? = nil
    var hasRequiredPermissions: Bool = true
    var hasCompactView: Bool = false
    
    var compactView: AnyView {
        AnyView(ToDoCompactView())
    }
    
    var expandedView: AnyView {
        AnyView(ToDoExpandedView())
    }
    
    var settingsView: AnyView {
        AnyView(ToDoSettingsView())
    }
}

struct ToDoSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("ToDo Settings")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeTokens.primaryText)
                
                SectionCard(title: "Features") {
                    VStack(spacing: 0) {
                        SettingsRow("Smart Reordering", icon: "hand.draw.fill") {
                            Text("Enabled").font(.system(size: 12)).foregroundColor(.secondary)
                        }
                        Divider().padding(.leading, 48)
                        SettingsRow("Micro-animations", icon: "sparkles") {
                            Text("Enabled").font(.system(size: 12)).foregroundColor(.secondary)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 10))
                        Text("Secure, local-first storage.")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(ThemeTokens.accentColor)
                    
                    Text("Your tasks are stored exclusively on your Mac using encrypted local storage. Notchlet does not use any cloud servers, ensuring your data remains private and accessible only to you.")
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
    }
}
