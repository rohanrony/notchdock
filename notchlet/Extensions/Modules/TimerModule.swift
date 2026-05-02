import SwiftUI
import Combine
import AppKit

struct TimerCompactView: View {
    @ObservedObject var viewModel = TimerViewModel.shared
    
    var body: some View {
        HStack(spacing: 0) {
            // LEFT SIDE: Timer Icon
            Image(systemName: "timer")
                .font(.system(size: TimerViewModel.Constants.monospacedFontSize, weight: .medium))
                .foregroundColor(ThemeTokens.primaryText)
                .padding(.trailing, 4) // Very close to notch
            
            // CENTER: Hardware Notch Spacer
            Spacer()
                .frame(width: 190)
                .alignmentGuide(.notchCenter) { d in d[HorizontalAlignment.center] }
            
            // RIGHT SIDE: Timer Text (if running)
            if viewModel.isRunning {
                Text(viewModel.timeString)
                    .font(.system(size: TimerViewModel.Constants.monospacedFontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(ThemeTokens.primaryText)
                    .padding(.leading, 4) // Very close to notch
            }
        }
        .padding(.horizontal, 10) // Minimal outer padding
    }
}


struct TimerExpandedView: View {
    @ObservedObject var viewModel = TimerViewModel.shared
    @State private var editMinutes: String = ""
    @State private var editSeconds: String = ""
    @State private var isEditing: Bool = false
    @FocusState private var focusedField: TimerField?
    
    enum TimerField {
        case minutes, seconds
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 32) {
            // Left: Time Input/Display
            HStack(spacing: 0) {
                if isEditing && !viewModel.isRunning {
                    HStack(spacing: 0) {
                        TextField("00", text: $editMinutes)
                            .textFieldStyle(.plain)
                            .font(.system(size: TimerViewModel.Constants.expandedTimeFontSize, weight: .medium, design: .monospaced))
                            .frame(width: 45)
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .minutes)
                            .tint(ThemeTokens.secondaryText)
                            .onChange(of: editMinutes) { _, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered.count > 2 {
                                    editMinutes = String(filtered.prefix(2))
                                } else {
                                    editMinutes = filtered
                                }
                                if editMinutes.count == 2 {
                                    focusedField = .seconds
                                }
                            }
                            .onSubmit {
                                applyChanges()
                                isEditing = false
                            }
                            .autocorrectionDisabled()
                            .textContentType(.none)
                        
                        Text(":")
                            .font(.system(size: 36, weight: .medium, design: .monospaced))
                        
                        TextField("00", text: $editSeconds)
                            .textFieldStyle(.plain)
                            .font(.system(size: 36, weight: .medium, design: .monospaced))
                            .frame(width: 45)
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .seconds)
                            .tint(ThemeTokens.secondaryText)
                            .onChange(of: editSeconds) { _, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered.count > 2 {
                                    editSeconds = String(filtered.prefix(2))
                                } else {
                                    editSeconds = filtered
                                }
                            }
                            .onSubmit {
                                applyChanges()
                                isEditing = false
                            }
                            .autocorrectionDisabled()
                            .textContentType(.none)
                    }
                    .onAppear {
                        let parts = viewModel.timeString.split(separator: ":")
                        if parts.count == 2 {
                            editMinutes = String(parts[0])
                            editSeconds = String(parts[1])
                        }
                        focusedField = .minutes
                    }
                    .onDisappear {
                        focusedField = nil
                    }
                } else {
                    // Static Time Display (Tap to Edit)
                    Text(viewModel.timeString)
                        .font(.system(size: 36, weight: .medium, design: .monospaced))
                        .foregroundColor(ThemeTokens.primaryText)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !viewModel.isRunning {
                                withAnimation {
                                    isEditing = true
                                }
                            }
                        }
                        .help(!viewModel.isRunning ? "Click to set time" : "")
                }
            }
            
            // Right: Controls
            HStack(spacing: 16) {
                Button(action: {
                    if !viewModel.isRunning {
                        applyChanges()
                    }
                    viewModel.toggle()
                }) {
                    Image(systemName: viewModel.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(ThemeTokens.accentColor)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    viewModel.reset()
                    let parts = viewModel.timeString.split(separator: ":")
                    if parts.count == 2 {
                        editMinutes = String(parts[0])
                        editSeconds = String(parts[1])
                    }
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(ThemeTokens.secondaryText)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
        .frame(minWidth: 220) // Sleeker min width
    }
    
    private func applyChanges() {
        let mins = editMinutes.isEmpty ? "00" : (editMinutes.count == 1 ? "0\(editMinutes)" : editMinutes)
        let secs = editSeconds.isEmpty ? "00" : (editSeconds.count == 1 ? "0\(editSeconds)" : editSeconds)
        viewModel.setTime(from: "\(mins):\(secs)")
    }
}

struct TimerModule: NotchletExtension {
    var id: String = "com.notchlet.timer"
    var displayName: String = "Timer"
    var iconName: String = "timer"
    
    var isPremium: Bool = false
    var productID: String? = nil
    var hasRequiredPermissions: Bool = true
    
    /// Time display + controls rendered side by side
    var expandedMinWidth: CGFloat { TimerViewModel.Constants.expandedMinWidth }
    
    var compactView: AnyView {
        AnyView(TimerCompactView())
    }
    
    var expandedView: AnyView {
        AnyView(TimerExpandedView())
    }
    
    var settingsView: AnyView {
        AnyView(TimerSettingsView())
    }
}

struct TimerSettingsView: View {
    @ObservedObject var viewModel = TimerViewModel.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Timer Settings")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeTokens.primaryText)
                
                SectionCard(title: "Duration", subtitle: "Set the default duration for new timers.") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 16) {
                            Slider(value: Binding(
                                get: { Double(viewModel.defaultMinutes) },
                                set: { viewModel.defaultMinutes = Int($0) }
                            ), in: 1...60, step: 1)
                            .tint(ThemeTokens.accentColor)
                            
                            Text("\(viewModel.defaultMinutes)m")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(ThemeTokens.primaryText)
                                .frame(width: 40)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(ThemeTokens.accentColor.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                    .padding(16)
                }
                
                SectionCard(title: "Quick Controls") {
                    HStack(spacing: 12) {
                        Button(action: { viewModel.toggle() }) {
                            Label(viewModel.isRunning ? "Pause" : "Start", systemImage: viewModel.isRunning ? "pause.fill" : "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(viewModel.isRunning ? .orange : ThemeTokens.accentColor)
                        
                        Button(action: { viewModel.reset() }) {
                            Label("Reset", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(16)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 10))
                        Text("Privacy first.")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(ThemeTokens.accentColor)
                    
                    Text("Your timer settings and history are stored locally. Notchlet operates entirely on your Mac and does not transmit any activity data or usage patterns to external servers.")
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

// MARK: - ViewModel

class TimerViewModel: ObservableObject {
    static let shared = TimerViewModel()
    
    struct Constants {
        static let defaultMinutes: Int = AppConfig.shared.value(for: "timer", key: "default_duration", default: 25)
        static let tickInterval: TimeInterval = 1.0
        static let alarmSecondChimeDelay: TimeInterval = AppConfig.shared.value(for: "timer", key: "alarm_chime_delay", default: 0.4)
        static let alarmSoundName: String = "Glass"
        static let monospacedFontSize: CGFloat = 13
        static let expandedTimeFontSize: CGFloat = 36
        static let expandedMinWidth: CGFloat = CGFloat(AppConfig.shared.value(for: "timer", key: "expanded_min_width", default: 260.0))
    }
    
    @AppStorage("timer_default_minutes") var defaultMinutes: Int = Constants.defaultMinutes {
        didSet {
            // Update remaining time if not running
            if !isRunning {
                timeRemaining = TimeInterval(defaultMinutes * 60)
            }
        }
    }
    
    @Published var timeRemaining: TimeInterval = TimeInterval(Constants.defaultMinutes * 60)
    @Published var isRunning: Bool = false
    
    private var timer: Foundation.Timer?
    
    func setTime(from string: String) {
        guard !isRunning else { return }
        let components = string.split(separator: ":")
        if components.count == 2,
           let mins = TimeInterval(components[0]),
           let secs = TimeInterval(components[1]) {
            let newTime = mins * 60 + secs
            if newTime > 0 {
                timeRemaining = newTime
            }
        } else if components.count == 1,
                  let mins = TimeInterval(components[0]) {
            let newTime = mins * 60
            if newTime > 0 {
                timeRemaining = newTime
            }
        }
    }
    
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var compactTimeString: String {
        let minutes = Int(timeRemaining) / 60
        return "\(minutes)m"
    }
    
    private init() {
        // Initialize from storage
        self.timeRemaining = TimeInterval(defaultMinutes * 60)
    }
    
    func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }
    
    func start() {
        if timeRemaining <= 0 {
            timeRemaining = TimeInterval(defaultMinutes * 60)
        }
        isRunning = true
        timer = Foundation.Timer.scheduledTimer(withTimeInterval: Constants.tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common) // Keep running during UI interactions
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        timeRemaining = TimeInterval(defaultMinutes * 60)
    }
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            pause()
            playAlarm()
        }
    }
    
    private func playAlarm() {
        // Double chime
        NSSound(named: NSSound.Name(Constants.alarmSoundName))?.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.alarmSecondChimeDelay) {
            NSSound(named: NSSound.Name(Constants.alarmSoundName))?.play()
        }
    }
}
