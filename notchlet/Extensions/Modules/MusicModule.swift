import SwiftUI
import Combine

// MARK: - Music Manager

class MusicManager {
    static let shared = MusicManager()
    
    enum AuthStatus: String {
        case authorized
        case denied
        case unknown
    }
    
    enum PlayerApp: String, CaseIterable {
        case music = "Music"
        case spotify = "Spotify"
        case none = "None"
        
        var bundleID: String {
            switch self {
            case .music: return "com.apple.Music"
            case .spotify: return "com.spotify.client"
            case .none: return ""
            }
        }
        
        var appName: String {
            switch self {
            case .music: return "Music.app"
            case .spotify: return "Spotify.app"
            case .none: return ""
            }
        }
    }
    
    func isAppInstalled(bundleID: String) -> Bool {
        guard let app = PlayerApp.allCases.first(where: { $0.bundleID == bundleID }) else { return false }
        if app == .music { return true }
        
        // Simple filesystem check is 100% silent and avoids FSFindFolder -43 logs.
        let commonPaths = [
            "/Applications/\(app.appName)",
            "/System/Applications/\(app.appName)",
            "\(NSHomeDirectory())/Applications/\(app.appName)"
        ]
        
        for path in commonPaths {
            if FileManager.default.fileExists(atPath: path) { return true }
        }
        
        // Fallback: if it's running, it's installed.
        return isAppRunning(bundleID: bundleID)
    }
    
    func isAppRunning(bundleID: String) -> Bool {
        guard !bundleID.isEmpty else { return false }
        return !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty
    }
    
    func getAuthStatus(bundleID: String) -> AuthStatus {
        guard !bundleID.isEmpty else { return .unknown }
        
        // Only check permission for running apps to avoid procNotFound and FSFindFolder logs.
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        guard let app = runningApps.first else {
            return .unknown 
        }
        
        let target = NSAppleEventDescriptor(processIdentifier: app.processIdentifier)
        guard let aeDesc = target.aeDesc else { return .unknown }
        
        let status = AEDeterminePermissionToAutomateTarget(aeDesc, 0x3f3f3f3f, 0x3f3f3f3f, false)
        
        if status == -1743 { return .denied }
        if status == 0 { return .authorized }
        
        return .unknown
    }
    
    /// Runs an AppleScript via `/usr/bin/osascript` subprocess.
    /// This is intentionally NOT using NSAppleScript, which triggers FSFindFolder
    /// Carbon calls inside our process and pollutes the console with -43 errors.
    func runScript(_ source: String) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", source]
        
        let outPipe = Pipe()
        let errPipe = Pipe()
        task.standardOutput = outPipe
        task.standardError = errPipe
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            return nil
        }
        
        // Check for permission denial in stderr (-1743)
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        if let errStr = String(data: errData, encoding: .utf8), errStr.contains("-1743") {
            return "PERMISSION_DENIED"
        }
        
        guard task.terminationStatus == 0 else { return nil }
        
        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    struct FullState {
        var player: PlayerApp
        var title: String
        var artist: String
        var isPlaying: Bool
        var progress: Double
        var duration: TimeInterval
    }
    
    func fetchFullState(current: PlayerApp) -> FullState {
        let mRun = isAppRunning(bundleID: PlayerApp.music.bundleID)
        let sRun = isAppRunning(bundleID: PlayerApp.spotify.bundleID)
        
        let mAuth = getAuthStatus(bundleID: PlayerApp.music.bundleID) == .authorized
        let sAuth = getAuthStatus(bundleID: PlayerApp.spotify.bundleID) == .authorized
        
        // --- PHASE 1: Find any ACTIVELY PLAYING player ---
        
        if mRun && mAuth {
            let script = "tell application id \"\(PlayerApp.music.bundleID)\" to get (player state as text)"
            if let res = runScript(script), res.contains("playing") {
                var info = FullState(player: .music, title: "Not Playing", artist: "Music", isPlaying: true, progress: 0, duration: 1)
                let fullScript = "tell application id \"\(PlayerApp.music.bundleID)\"\ntry\nset tName to name of current track\nset aName to artist of current track\nset pPos to player position\nset pDur to duration of current track\nreturn \"title:\" & tName & \"|artist:\" & aName & \"|pos:\" & pPos & \"|dur:\" & pDur\non error\nreturn \"error\"\nend try\nend tell"
                if let data = runScript(fullScript), data != "error" {
                    parse(data, into: &info)
                    info.isPlaying = true // Ensure it stays true
                    return info
                }
            }
        }
        
        if sRun && sAuth {
            let script = "tell application id \"\(PlayerApp.spotify.bundleID)\" to get (player state as text)"
            if let res = runScript(script), res.contains("playing") {
                var info = FullState(player: .spotify, title: "Not Playing", artist: "Spotify", isPlaying: true, progress: 0, duration: 1)
                let fullScript = "tell application id \"\(PlayerApp.spotify.bundleID)\"\ntry\nset tName to name of current track\nset aName to artist of current track\nset pPos to player position\nset pDur to (duration of current track) / 1000\nreturn \"title:\" & tName & \"|artist:\" & aName & \"|pos:\" & pPos & \"|dur:\" & pDur\non error\nreturn \"error\"\nend try\nend tell"
                if let data = runScript(fullScript), data != "error" {
                    parse(data, into: &info)
                    info.isPlaying = true
                    return info
                }
            }
        }
        
        // --- PHASE 2: Fallback to static priority if nothing is playing ---
        
        if mRun {
            var info = FullState(player: .music, title: "Not Playing", artist: "Music", isPlaying: false, progress: 0, duration: 1)
            if mAuth {
                let script = "tell application id \"\(PlayerApp.music.bundleID)\"\ntry\nset tName to name of current track\nset aName to artist of current track\nreturn \"title:\" & tName & \"|artist:\" & aName\non error\nreturn \"error\"\nend try\nend tell"
                if let data = runScript(script), data != "error" {
                    parse(data, into: &info)
                }
            }
            return info
        }
        
        if sRun {
            var info = FullState(player: .spotify, title: "Not Playing", artist: "Spotify", isPlaying: false, progress: 0, duration: 1)
            if sAuth {
                let script = "tell application id \"\(PlayerApp.spotify.bundleID)\"\ntry\nset tName to name of current track\nset aName to artist of current track\nreturn \"title:\" & tName & \"|artist:\" & aName\non error\nreturn \"error\"\nend try\nend tell"
                if let data = runScript(script), data != "error" {
                    parse(data, into: &info)
                }
            }
            return info
        }
        
        return FullState(player: .none, title: "Not Playing", artist: "No Media Detected", isPlaying: false, progress: 0, duration: 1)
    }
    
    private func parse(_ res: String, into info: inout FullState) {
        let parts = res.components(separatedBy: "|")
        for part in parts {
            let kv = part.components(separatedBy: ":")
            if kv.count < 2 { continue }
            let k = kv[0], v = kv[1]
            switch k {
            case "playing": info.isPlaying = (v == "true")
            case "title": info.title = v
            case "artist": info.artist = v
            case "pos": 
                let p = Double(v) ?? 0
                info.progress = info.duration > 0 ? p / info.duration : 0
            case "dur": 
                info.duration = Double(v) ?? 1
                // Re-calculate progress if we have duration now
                if let posPart = parts.first(where: { $0.hasPrefix("pos:") }) {
                    let posVal = Double(posPart.components(separatedBy: ":")[1]) ?? 0
                    info.progress = info.duration > 0 ? posVal / info.duration : 0
                }
            default: break
            }
        }
    }
    
    /// Send play/pause to a known player. Caller supplies the player so we skip a redundant subprocess query.
    func togglePlay(player: PlayerApp) {
        let target = player == .none ? .music : player
        DispatchQueue.global(qos: .userInitiated).async {
            _ = self.runScript("tell application id \"\(target.bundleID)\" to playpause")
        }
    }
    
    func nextTrack(player: PlayerApp) {
        guard player == .music || player == .spotify else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            _ = self.runScript("tell application id \"\(player.bundleID)\" to next track")
        }
    }
    
    func previousTrack(player: PlayerApp) {
        guard player == .music || player == .spotify else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            let cmd = player == .music ? "back track" : "previous track"
            _ = self.runScript("tell application id \"\(player.bundleID)\" to \(cmd)")
        }
    }
    
    /// Seek to an absolute position in seconds for Music or Spotify.
    func seek(to seconds: Double, player: PlayerApp) {
        guard player == .music || player == .spotify else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            _ = self.runScript("tell application id \"\(player.bundleID)\" to set player position to \(seconds)")
        }
    }
}

class MusicViewModel: ObservableObject {
    static let shared = MusicViewModel()
    @Published var trackTitle: String = "Not Playing"
    @Published var artistName: String = "No Media Detected"
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0.0
    @Published var accentColor: Color = Color(red: 0.8, green: 0.2, blue: 0.5)
    @Published var musicAuth: MusicManager.AuthStatus = .unknown
    @Published var spotifyAuth: MusicManager.AuthStatus = .unknown
    @Published var musicInstalled: Bool = false
    @Published var spotifyInstalled: Bool = false
    @Published var hasPermission: Bool = true
    @Published var anyAuthConfirmed: Bool = false
    @Published var showCompact: Bool = true { didSet { UserDefaults.standard.set(showCompact, forKey: "music_show_compact") } }

    var duration: TimeInterval = 1
    /// The last confirmed active player — used by controls to avoid re-querying.
    private(set) var activePlayer: MusicManager.PlayerApp = .none
    private var timer: Timer?
    private var isRefreshing = false
    /// Prevents the poll from overwriting progress while the user is dragging.
    var isDraggingSlider: Bool = false

    init() {
        self.showCompact = UserDefaults.standard.object(forKey: "music_show_compact") as? Bool ?? true
        startPolling()
        refreshInfo()
    }

    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.refreshInfo()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func refreshInfo() {
        guard !isRefreshing else { return }
        isRefreshing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let manager = MusicManager.shared
            let mIns = manager.isAppInstalled(bundleID: MusicManager.PlayerApp.music.bundleID)
            let sIns = manager.isAppInstalled(bundleID: MusicManager.PlayerApp.spotify.bundleID)
            let mAuth = manager.getAuthStatus(bundleID: MusicManager.PlayerApp.music.bundleID)
            let sAuth = manager.getAuthStatus(bundleID: MusicManager.PlayerApp.spotify.bundleID)
            
            let state = manager.fetchFullState(current: self.activePlayer)
            
            DispatchQueue.main.async {
                self.musicInstalled = mIns; self.spotifyInstalled = sIns
                self.musicAuth = mAuth; self.spotifyAuth = sAuth
                
                let mRun = manager.isAppRunning(bundleID: MusicManager.PlayerApp.music.bundleID)
                let sRun = manager.isAppRunning(bundleID: MusicManager.PlayerApp.spotify.bundleID)

                let musicNeedsFix = mRun && mAuth == .denied
                let spotifyNeedsFix = sRun && sAuth == .denied
                self.hasPermission = !(musicNeedsFix || spotifyNeedsFix)
                self.anyAuthConfirmed = [mAuth, sAuth].contains(.authorized)
                
                self.activePlayer = state.player
                self.trackTitle = state.title
                self.artistName = state.artist
                self.isPlaying = state.isPlaying
                if !self.isDraggingSlider {
                    self.progress = state.progress
                }
                self.duration = state.duration
                
                self.isRefreshing = false
            }
        }
    }

    func requestPermission(for app: MusicManager.PlayerApp) {
        _ = MusicManager.shared.runScript("tell application id \"\(app.bundleID)\" to get name")
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
            NSWorkspace.shared.open(url)
        }
    }

    func togglePlay() {
        // Optimistic toggle is removed because it causes desync with incorrect active player detection.
        MusicManager.shared.togglePlay(player: activePlayer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { self.refreshInfo() }
    }

    func nextTrack() {
        MusicManager.shared.nextTrack(player: activePlayer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.refreshInfo() }
    }

    func previousTrack() {
        MusicManager.shared.previousTrack(player: activePlayer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.refreshInfo() }
    }

    func seek(to pct: Double) {
        let seconds = pct * duration
        progress = pct
        MusicManager.shared.seek(to: seconds, player: activePlayer)
    }

    var currentTimeString: String {
        let current = duration * progress
        return String(format: "%d:%02d", Int(current) / 60, Int(current) % 60)
    }
    var totalTimeString: String {
        return String(format: "%d:%02d", Int(duration) / 60, Int(duration) % 60)
    }
}

struct MusicPremiumSlider: View {
    @Binding var value: Double
    var fillColor: Color = .white
    var height: CGFloat = 4
    var knobSize: CGFloat = 10
    /// Called continuously as the user drags.
    var onDragging: ((Double) -> Void)? = nil
    /// Called once when the user releases the slider — use this to seek.
    var onCommit: ((Double) -> Void)? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1)).frame(height: height)
                Capsule().fill(fillColor).frame(width: CGFloat(value) * geo.size.width, height: height)
                Circle().fill(Color.white).frame(width: knobSize, height: knobSize)
                    .offset(x: CGFloat(value) * geo.size.width - knobSize / 2)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { val in
                        let pct = min(max(0, Double(val.location.x / geo.size.width)), 1)
                        value = pct
                        onDragging?(pct)
                    }
                    .onEnded { val in
                        let pct = min(max(0, Double(val.location.x / geo.size.width)), 1)
                        value = pct
                        onCommit?(pct)
                    }
            )
        }
        .frame(height: max(height, knobSize))
    }
}

struct MusicVisualizerView: View {
    @ObservedObject var viewModel = MusicViewModel.shared; @State private var heights: [CGFloat] = [4, 4, 4, 4]
    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<heights.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1).fill(viewModel.accentColor).frame(width: 2, height: heights[i]).animation(.spring(response: 0.2, dampingFraction: 0.5), value: heights[i])
            }
        }.frame(height: 14).onReceive(timer) { _ in if viewModel.isPlaying { heights = (0..<4).map { _ in CGFloat.random(in: 4...14) } } else { heights = [4, 4, 4, 4] } }
    }
}

struct MusicCompactView: View {
    @ObservedObject var viewModel = MusicViewModel.shared
    var body: some View {
        if viewModel.showCompact {
            HStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous).fill(LinearGradient(colors: [viewModel.accentColor, viewModel.accentColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 18, height: 18)
                    Image(systemName: "music.note").font(.system(size: 10)).foregroundColor(.white.opacity(0.8))
                }.padding(.trailing, 8)
                Spacer().frame(width: 190).alignmentGuide(.notchCenter) { d in d[HorizontalAlignment.center] }
                MusicVisualizerView().padding(.leading, 8)
            }.padding(.horizontal, 12)
        } else { Spacer().frame(width: 190).alignmentGuide(.notchCenter) { d in d[HorizontalAlignment.center] } }
    }
}

struct MusicExpandedView: View {
    @ObservedObject var viewModel = MusicViewModel.shared
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(LinearGradient(colors: [viewModel.accentColor, viewModel.accentColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 52, height: 52).overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    Image(systemName: "music.note").font(.system(size: 22, weight: .light)).foregroundColor(.white.opacity(0.5))
                }.shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.trackTitle).font(ThemeTokens.font(size: 15, weight: .bold)).foregroundColor(ThemeTokens.primaryText).lineLimit(1)
                    Text(viewModel.artistName).font(ThemeTokens.font(size: 13, weight: .medium)).foregroundColor(ThemeTokens.secondaryText).lineLimit(1)
                }
                Spacer()
            }
            VStack(spacing: 6) {
                MusicPremiumSlider(
                    value: $viewModel.progress,
                    fillColor: viewModel.accentColor,
                    onDragging: { _ in
                        viewModel.isDraggingSlider = true
                    },
                    onCommit: { pct in
                        viewModel.isDraggingSlider = false
                        viewModel.seek(to: pct)
                    }
                )
                HStack { Text(viewModel.currentTimeString); Spacer(); Text("-\(viewModel.totalTimeString)") }
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(ThemeTokens.secondaryText)
            }
            HStack(spacing: 24) {
                Button(action: { viewModel.previousTrack() }) { Image(systemName: "backward.fill").font(.system(size: 18)) }.buttonStyle(.plain)
                Button(action: { viewModel.togglePlay() }) { Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill").font(.system(size: 24)).frame(width: 28) }.buttonStyle(.plain)
                Button(action: { viewModel.nextTrack() }) { Image(systemName: "forward.fill").font(.system(size: 18)) }.buttonStyle(.plain)
            }.foregroundColor(ThemeTokens.primaryText)
        }.padding(.horizontal, 24).padding(.top, 12).padding(.bottom, viewModel.hasPermission ? 24 : 8)
        if !viewModel.hasPermission { HStack(spacing: 6) { Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 10)); Text("Access Required. Check Settings.").font(ThemeTokens.font(size: 10, weight: .semibold)) }.foregroundColor(.orange).padding(.bottom, 12) }
        else if !viewModel.anyAuthConfirmed { Text("No music sources authorized. Visit Settings.").font(ThemeTokens.font(size: 9)).foregroundColor(ThemeTokens.secondaryText.opacity(0.5)).padding(.bottom, 8) }
    }
}

struct MusicSettingsView: View {
    @ObservedObject var viewModel = MusicViewModel.shared
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Music Settings").font(.title2).bold()
                VStack(alignment: .leading, spacing: 16) {
                    Toggle(isOn: $viewModel.showCompact) { VStack(alignment: .leading, spacing: 4) { Text("Show in Compact Mode").font(ThemeTokens.font(size: 15, weight: .semibold)); Text("Show thumbnail and visualizer when minimized.").font(ThemeTokens.font(size: 13)).foregroundColor(ThemeTokens.secondaryText) } }.toggleStyle(.switch)
                }.padding().background(ThemeTokens.secondaryText.opacity(0.05)).cornerRadius(12)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Permissions & Sources").font(ThemeTokens.font(size: 14, weight: .bold)).foregroundColor(ThemeTokens.secondaryText)
                    VStack(spacing: 8) {
                        if viewModel.musicInstalled && viewModel.musicAuth != .authorized { MusicPermissionRow(name: "Apple Music", icon: "music.note", action: { viewModel.requestPermission(for: .music) }) }
                        if viewModel.spotifyInstalled && viewModel.spotifyAuth != .authorized { MusicPermissionRow(name: "Spotify", icon: "play.circle.fill", action: { viewModel.requestPermission(for: .spotify) }) }
                        if viewModel.anyAuthConfirmed && viewModel.hasPermission { HStack { Image(systemName: "checkmark.circle.fill").foregroundColor(.green); Text("Sources authorized").font(ThemeTokens.font(size: 13)); Spacer() }.padding(.top, 4) }
                    }
                }.padding().background(ThemeTokens.secondaryText.opacity(0.05)).cornerRadius(12)
            }.padding(24)
        }
    }
}

struct MusicPermissionRow: View {
    let name: String; let icon: String; let action: () -> Void
    var body: some View {
        HStack {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(ThemeTokens.secondaryText).frame(width: 20)
            Text(name).font(ThemeTokens.font(size: 14, weight: .medium)); Spacer()
            Button(action: action) { Text("Allow Access").font(ThemeTokens.font(size: 11, weight: .bold)).padding(.horizontal, 10).padding(.vertical, 4).background(ThemeTokens.accentColor).foregroundColor(.white).cornerRadius(6) }.buttonStyle(.plain)
        }.padding(.vertical, 4)
    }
}

struct MusicModule: NotchletExtension {
    var id: String = "com.notchlet.music"
    var displayName: String = "Music"; var iconName: String = "music.note"; var isPremium: Bool = false; var productID: String? = nil; var hasRequiredPermissions: Bool { true }; var expandedMinWidth: CGFloat { AppConfig.Music.expandedMinWidth }; var compactView: AnyView { AnyView(MusicCompactView()) }; var expandedView: AnyView { AnyView(MusicExpandedView()) }; var settingsView: AnyView { AnyView(MusicSettingsView()) }
}
