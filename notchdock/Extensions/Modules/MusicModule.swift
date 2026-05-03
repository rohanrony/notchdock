import SwiftUI
import Combine
import CoreImage
import os.log

// MARK: - Music Manager

extension String {
    func sanitizedForAppleScript() -> String {
        return self.replacingOccurrences(of: "\\", with: "\\\\")
                   .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

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
        // We no longer call AEDeterminePermissionToAutomateTarget here because it 
        // triggers 'procNotFound' console spam on macOS Sequoia when sandboxed.
        // The permission status is now 'learned' from actual AppleScript results.
        return .unknown
    }
    
    /// Runs an AppleScript via `/usr/bin/osascript` subprocess.
    /// This is intentionally NOT using NSAppleScript, which triggers FSFindFolder
    /// Carbon calls inside our process and pollutes the console with -43 errors.
    func runScript(_ source: String) -> String? {
        guard let script = NSAppleScript(source: source) else {
            NotchLog.error("Failed to initialize NSAppleScript", category: NotchLog.music)
            return nil
        }
        
        var error: NSDictionary?
        let result = script.executeAndReturnError(&error)
        
        if let error = error {
            let errMsg = error["NSAppleScriptErrorMessage"] as? String ?? "Unknown Error"
            NotchLog.error("NSAppleScript Error: \(errMsg)", category: NotchLog.security)
            
            if errMsg.contains("privilege violation") || errMsg.contains("Not authorized") || errMsg.contains("-1743") {
                return "PERMISSION_DENIED"
            }
            return nil
        }
        
        return result.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    struct FullState {
        var player: PlayerApp
        var title: String
        var artist: String
        var isPlaying: Bool
        var progress: Double
        var duration: TimeInterval
        var artworkURL: String?
        var artworkData: Data?
    }
    
    func fetchFullState(current: PlayerApp) -> FullState {
        let mRun = isAppRunning(bundleID: PlayerApp.music.bundleID)
        let sRun = isAppRunning(bundleID: PlayerApp.spotify.bundleID)
        
        let mAuthStatus = getAuthStatus(bundleID: PlayerApp.music.bundleID)
        let sAuthStatus = getAuthStatus(bundleID: PlayerApp.spotify.bundleID)
        
        let mCanTry = mAuthStatus == .authorized || mAuthStatus == .unknown
        let sCanTry = sAuthStatus == .authorized || sAuthStatus == .unknown
        
        // --- PHASE 1: Find any ACTIVELY PLAYING player ---
        
        if mRun && mCanTry {
            let script = "tell application id \"\(PlayerApp.music.bundleID)\"\ntry\nget (player state as text)\non error\nreturn \"stopped\"\nend try\nend tell"
            if let res = runScript(script) {
                if res == "PERMISSION_DENIED" {
                    return FullState(player: .music, title: "PERMISSION_DENIED", artist: "", isPlaying: false, progress: 0, duration: 1)
                }
                if res.contains("playing") {
                    var info = FullState(player: .music, title: "Not Playing", artist: "Music", isPlaying: true, progress: 0, duration: 1)
                    let fullScript = "tell application id \"\(PlayerApp.music.bundleID)\"\ntry\nset tName to name of current track\nset aName to artist of current track\nset pPos to player position\nset pDur to duration of current track\nreturn \"title:\" & tName & \"«»artist:\" & aName & \"«»pos:\" & pPos & \"«»dur:\" & pDur\non error\nreturn \"error\"\nend try\nend tell"
                    if let data = runScript(fullScript), data != "error" {
                        parse(data, into: &info)
                        info.isPlaying = true
                        return info
                    }
                }
            }
        }
        
        if sRun && sCanTry {
            let script = "tell application id \"\(PlayerApp.spotify.bundleID)\"\ntry\nget (player state as text)\non error\nreturn \"stopped\"\nend try\nend tell"
            if let res = runScript(script) {
                if res == "PERMISSION_DENIED" {
                    return FullState(player: .spotify, title: "PERMISSION_DENIED", artist: "", isPlaying: false, progress: 0, duration: 1)
                }
                if res.contains("playing") {
                    var info = FullState(player: .spotify, title: "Not Playing", artist: "Spotify", isPlaying: true, progress: 0, duration: 1)
                    let fullScript = "tell application id \"\(PlayerApp.spotify.bundleID)\"\ntry\nset tName to name of current track\nset aName to artist of current track\nset pPos to player position\nset pDur to (duration of current track) / 1000\nset aURL to artwork url of current track\nreturn \"title:\" & tName & \"«»artist:\" & aName & \"«»pos:\" & pPos & \"«»dur:\" & pDur & \"«»art:\" & aURL\non error\nreturn \"error\"\nend try\nend tell"
                    if let data = runScript(fullScript), data != "error" {
                        parse(data, into: &info)
                        info.isPlaying = true
                        return info
                    }
                }
            }
        }
        
        // --- PHASE 2: Fallback to static priority if nothing is playing ---
        
        if mRun {
            var info = FullState(player: .music, title: "Not Playing", artist: "Music", isPlaying: false, progress: 0, duration: 1)
            if mCanTry {
                let script = "tell application id \"\(PlayerApp.music.bundleID)\"\ntry\nset tName to name of current track\nset aName to artist of current track\nreturn \"title:\" & tName & \"«»artist:\" & aName\non error\nreturn \"error\"\nend try\nend tell"
                if let data = runScript(script), data != "error" {
                    parse(data, into: &info)
                }
            }
            return info
        }
        
        if sRun {
            var info = FullState(player: .spotify, title: "Not Playing", artist: "Spotify", isPlaying: false, progress: 0, duration: 1)
            if sCanTry {
                let script = "tell application id \"\(PlayerApp.spotify.bundleID)\"\ntry\nset tName to name of current track\nset aName to artist of current track\nreturn \"title:\" & tName & \"«»artist:\" & aName\non error\nreturn \"error\"\nend try\nend tell"
                if let data = runScript(script), data != "error" {
                    parse(data, into: &info)
                }
            }
            return info
        }
        
        return FullState(player: .none, title: "Not Playing", artist: "No Media Detected", isPlaying: false, progress: 0, duration: 1)
    }
    
    private func parse(_ res: String, into info: inout FullState) {
        let parts = res.components(separatedBy: "«»")
        for part in parts {
            let kv = part.components(separatedBy: ":")
            if kv.count < 2 { continue }
            let k = kv[0]
            let v = part.replacingOccurrences(of: "\(k):", with: "")
            
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
                    let posVal = Double(posPart.replacingOccurrences(of: "pos:", with: "")) ?? 0
                    info.progress = info.duration > 0 ? posVal / info.duration : 0
                }
            case "art":
                info.artworkURL = v
            default: break
            }
        }
    }
    
    func fetchMusicArtwork() -> Data? {
        guard isAppRunning(bundleID: PlayerApp.music.bundleID) else { return nil }
        
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("notchdock_art.png")
        let tempPath = tempURL.path
        // Use a more robust AppleScript for saving artwork
        let saveScript = """
        tell application id "\(PlayerApp.music.bundleID)"
            try
                if not (exists (artwork 1 of current track)) then return "no_art"
                set srcData to raw data of artwork 1 of current track
                set theFile to POSIX file "\(tempPath)"
                set f to open for access theFile with write permission
                set eof of f to 0
                write srcData to f
                close access f
                return "ok"
            on error err
                try
                    close access POSIX file "\(tempPath)"
                end try
                return "error: " & err
            end try
        end tell
        """
        
        let result = runScript(saveScript)
        if result == "ok" {
            return try? Data(contentsOf: tempURL)
        }
        return nil
    }
    
    /// Send play/pause to a known player. Caller supplies the player so we skip a redundant subprocess query.
    func togglePlay(player: PlayerApp) {
        let target = player == .none ? .music : player
        let bundleID = target.bundleID
        
        DispatchQueue.global(qos: .userInitiated).async {
            let isRunning = !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty
            
            if isRunning {
                let appName = target == .music ? "Music" : "Spotify"
                let scriptSource = """
                tell application "\(appName)"
                    if player state is playing then
                        pause
                    else
                        play
                    end if
                end tell
                """
                
                if let script = NSAppleScript(source: scriptSource) {
                    var error: NSDictionary?
                    script.executeAndReturnError(&error)
                    if let error = error {
                        NotchLog.error("NSAppleScript Error: \(error)", category: NotchLog.music)
                    } else {
                        NotchLog.info("NSAppleScript Play/Pause successful", category: NotchLog.music)
                    }
                }
            } else {
                NotchLog.info("Launching \(bundleID) in background...", category: NotchLog.music)
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
                    let config = NSWorkspace.OpenConfiguration()
                    config.addsToRecentItems = false
                    config.activates = false
                    
                    NSWorkspace.shared.openApplication(at: url, configuration: config) { app, error in
                        if let error = error {
                            NotchLog.error("Failed to launch \(bundleID): \(error.localizedDescription)", category: NotchLog.music)
                        } else {
                            Thread.sleep(forTimeInterval: 1.0)
                            self.togglePlay(player: target)
                        }
                    }
                }
            }
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
    @Published var artworkImage: NSImage? = nil
    @Published var appIconImage: NSImage? = nil
    @Published var showCompact: Bool = true { didSet { UserDefaults.standard.set(showCompact, forKey: "music_show_compact") } }

    var duration: TimeInterval = 1
    /// The last confirmed active player — used by controls to avoid re-querying.
    private(set) var activePlayer: MusicManager.PlayerApp = .none {
        didSet { if activePlayer != oldValue { updateAppIcon() } }
    }
    private var timer: Timer?
    private var isRefreshing = false
    /// Prevents the poll from overwriting progress while the user is dragging.
    var isDraggingSlider: Bool = false
    /// Tracks which titles have already failed artwork fetching to avoid spamming.
    private var failedArtworkTitles = Set<String>()

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
            var mAuth = self.musicAuth
            var sAuth = self.spotifyAuth
            
            let state = manager.fetchFullState(current: self.activePlayer)
            
            // If the script returned PERMISSION_DENIED or a privilege violation, 
            // we know the status is .denied.
            if state.player == .music && (state.title == "PERMISSION_DENIED" || state.title.contains("privilege violation")) { mAuth = .denied }
            if state.player == .spotify && (state.title == "PERMISSION_DENIED" || state.title.contains("privilege violation")) { sAuth = .denied }
            
            DispatchQueue.main.async {
                self.musicInstalled = mIns; self.spotifyInstalled = sIns
                self.musicAuth = mAuth; self.spotifyAuth = sAuth
                
                let mRun = manager.isAppRunning(bundleID: MusicManager.PlayerApp.music.bundleID)
                let sRun = manager.isAppRunning(bundleID: MusicManager.PlayerApp.spotify.bundleID)
                
                // Silent Permission Learning: 
                // If an app is running but we don't know its status, do a one-time lightweight check.
                // This 'teaches' the app that it is authorized without aggressive polling.
                if mRun && self.musicAuth == .unknown {
                    let res = manager.runScript("tell application id \"\(MusicManager.PlayerApp.music.bundleID)\" to get name")
                    if res == "PERMISSION_DENIED" || res?.contains("privilege violation") == true { self.musicAuth = .denied }
                    else if res != nil { self.musicAuth = .authorized }
                }
                if sRun && self.spotifyAuth == .unknown {
                    let res = manager.runScript("tell application id \"\(MusicManager.PlayerApp.spotify.bundleID)\" to get name")
                    if res == "PERMISSION_DENIED" || res?.contains("privilege violation") == true { self.spotifyAuth = .denied }
                    else if res != nil { self.spotifyAuth = .authorized }
                }

                let musicNeedsFix = mRun && mAuth == .denied
                let spotifyNeedsFix = sRun && sAuth == .denied
                self.hasPermission = !(musicNeedsFix || spotifyNeedsFix)
                self.anyAuthConfirmed = [mAuth, sAuth].contains(.authorized)
                
                self.activePlayer = state.player
                self.duration = state.duration
                self.artistName = state.artist
                self.isPlaying = state.isPlaying
                if !self.isDraggingSlider {
                    self.progress = state.progress
                }
                
                // Artwork Handling
                if state.title != self.trackTitle {
                    self.artworkImage = nil
                    
                    // Immediately apply fallback color so the UI changes even if art takes time
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.accentColor = self.colorForName(state.artist)
                    }
                    
                    if state.player == .spotify, let urlStr = state.artworkURL, let url = URL(string: urlStr) {
                        self.loadArtwork(from: url)
                    } else if state.player == .music {
                        self.loadMusicArtwork()
                    } else if state.player == .none {
                        self.accentColor = Color(red: 0.8, green: 0.2, blue: 0.5)
                    }
                } else if self.artworkImage == nil && state.player != .none && !self.failedArtworkTitles.contains(state.title) {
                    // Retry once if we don't have art and haven't failed yet
                    if state.player == .spotify, let urlStr = state.artworkURL, let url = URL(string: urlStr) {
                        self.loadArtwork(from: url)
                    } else if state.player == .music {
                        self.loadMusicArtwork()
                    }
                }
                
                self.trackTitle = state.title
                self.isRefreshing = false
            }
        }
    }

    private func loadArtwork(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let img = NSImage(data: data) {
                DispatchQueue.main.async {
                    self.artworkImage = img
                    self.extractColor(from: img)
                }
            } else {
                DispatchQueue.main.async {
                    self.extractColor(from: nil)
                }
            }
        }.resume()
    }

    private func loadMusicArtwork() {
        let currentTitle = self.trackTitle
        DispatchQueue.global(qos: .background).async {
            if let data = MusicManager.shared.fetchMusicArtwork(), let img = NSImage(data: data) {
                DispatchQueue.main.async {
                    self.artworkImage = img
                    self.extractColor(from: img)
                }
            } else {
                DispatchQueue.main.async {
                    self.failedArtworkTitles.insert(currentTitle)
                    self.extractColor(from: nil)
                }
            }
        }
    }

    private func extractColor(from image: NSImage?) {
        if let image = image, let color = image.dominantColor() {
            withAnimation(.easeInOut(duration: 0.8)) {
                self.accentColor = color
            }
        } else {
            // Fallback to deterministic color if image is nil or extraction fails
            // Use artist name if available, otherwise track title to ensure variety
            let fallbackName = self.artistName.count > 2 ? self.artistName : self.trackTitle
            withAnimation(.easeInOut(duration: 0.8)) {
                self.accentColor = self.colorForName(fallbackName)
            }
        }
    }
    
    private func colorForName(_ name: String) -> Color {
        let hash = abs(name.hashValue)
        let h = Double(hash % 360) / 360.0
        return Color(hue: h, saturation: 0.7, brightness: 0.8)
    }

    func requestPermission(for app: MusicManager.PlayerApp) {
        _ = MusicManager.shared.runScript("tell application id \"\(app.bundleID)\" to get name")
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func updateAppIcon() {
        let bundleID = activePlayer.bundleID
        if bundleID.isEmpty || activePlayer == .none {
            self.appIconImage = nil
            return
        }
        
        // Using static symbols instead of fetching the app icon from disk 
        // avoids the NSWorkspace calls that trigger Sequoia's entitlement warnings.
        let symbolName = activePlayer == .spotify ? "play.circle.fill" : "apple.logo"
        let config = NSImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        self.appIconImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
            .withSymbolConfiguration(config)
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

    func openActivePlayer() {
        let bundleID = activePlayer.bundleID
        guard !bundleID.isEmpty && activePlayer != .none else { return }
        
        // Reverting to file-based open as it's the most reliable across all systems
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            NSWorkspace.shared.open(url)
        }
    }

    var activePlayerIcon: NSImage? {
        return appIconImage
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
                    if let img = viewModel.artworkImage {
                        Image(nsImage: img).resizable().aspectRatio(contentMode: .fill)
                            .frame(width: 18, height: 18).cornerRadius(4)
                    } else {
                        RoundedRectangle(cornerRadius: 4, style: .continuous).fill(LinearGradient(colors: [viewModel.accentColor, viewModel.accentColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 18, height: 18)
                        Image(systemName: "music.note").font(.system(size: 10)).foregroundColor(.white.opacity(0.8))
                    }
                }.padding(.trailing, 8)
                Spacer().frame(width: 190).alignmentGuide(.notchCenter) { d in d[HorizontalAlignment.center] }
                MusicVisualizerView().padding(.leading, 8)
            }.padding(.horizontal, 12)
        } else { Spacer().frame(width: 190).alignmentGuide(.notchCenter) { d in d[HorizontalAlignment.center] } }
    }
}

struct MusicAppButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct MusicExpandedView: View {
    @ObservedObject var viewModel = MusicViewModel.shared
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    if let img = viewModel.artworkImage {
                        Image(nsImage: img).resizable().aspectRatio(contentMode: .fill)
                            .frame(width: 52, height: 52).cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous).fill(LinearGradient(colors: [viewModel.accentColor, viewModel.accentColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 52, height: 52).overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                        Image(systemName: "music.note").font(.system(size: 22, weight: .light)).foregroundColor(.white.opacity(0.5))
                    }
                }.shadow(color: viewModel.accentColor.opacity(0.3), radius: 12, x: 0, y: 6)
                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.trackTitle).font(ThemeTokens.font(size: 15, weight: .medium)).foregroundColor(ThemeTokens.primaryText).lineLimit(1)
                    Text(viewModel.artistName).font(ThemeTokens.font(size: 13, weight: .medium)).foregroundColor(ThemeTokens.secondaryText).lineLimit(1)
                }
                Spacer()
                
                if viewModel.activePlayer != .none {
                    Button(action: { viewModel.openActivePlayer() }) {
                        if let appIcon = viewModel.appIconImage {
                            Image(nsImage: appIcon)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 13, height: 13)
                                .foregroundColor(ThemeTokens.secondaryText)
                                .frame(width: 24, height: 24)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                        }
                    }
                    .buttonStyle(MusicAppButtonStyle())
                    .help("Open in \(viewModel.activePlayer.rawValue)")
                }
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
            VStack(alignment: .leading, spacing: 28) {
                Text("Music Settings")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeTokens.primaryText)
                
                SectionCard(title: "Display", subtitle: "Configure how music info appears in the notch.") {
                    SettingsRow("Show in Compact Mode", icon: "square.stack.3d.up.fill") {
                        Toggle("", isOn: $viewModel.showCompact)
                            .toggleStyle(.switch)
                            .scaleEffect(0.8)
                    }
                }
                
                SectionCard(title: "Permissions & Sources", subtitle: "Authorize NotchDock to control your music players.") {
                    VStack(spacing: 0) {
                        if viewModel.musicInstalled {
                            MusicPermissionRow(
                                name: "Apple Music",
                                icon: "apple.logo",
                                status: viewModel.musicAuth,
                                action: { viewModel.requestPermission(for: .music) }
                            )
                            if viewModel.spotifyInstalled { Divider().padding(.leading, 48) }
                        }
                        
                        if viewModel.spotifyInstalled {
                            MusicPermissionRow(
                                name: "Spotify",
                                icon: "play.circle.fill",
                                status: viewModel.spotifyAuth,
                                action: { viewModel.requestPermission(for: .spotify) }
                            )
                        }
                        
                        if !viewModel.musicInstalled && !viewModel.spotifyInstalled {
                            HStack {
                                Text("No supported music apps detected.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(16)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 10))
                        Text("NotchDock is fully local. Your data never leaves your Mac.")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(ThemeTokens.accentColor)
                    
                    Text("We request automation access only to bridge your music players with the notch. This allows us to fetch track details and provide playback controls without any internet connection or server-side processing.")
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

struct MusicPermissionRow: View {
    let name: String
    let icon: String
    let status: MusicManager.AuthStatus
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(ThemeTokens.accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.system(size: 14, weight: .medium))
                Text(statusText)
                    .font(.system(size: 11))
                    .foregroundColor(statusColor)
            }
            
            Spacer()
            
            if status != .authorized {
                Button(action: action) {
                    Text(status == .denied ? "Fix in Settings" : "Allow Access")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(ThemeTokens.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    var statusText: String {
        switch status {
        case .authorized: return "Authorized"
        case .denied: return "Access Denied"
        case .unknown: return "Access Not Requested"
        }
    }
    
    var statusColor: Color {
        switch status {
        case .authorized: return .green.opacity(0.8)
        case .denied: return .red.opacity(0.8)
        case .unknown: return ThemeTokens.secondaryText.opacity(0.6)
        }
    }
}

struct MusicModule: NotchDockExtension {
    struct Constants {
        static let expandedMinWidth: CGFloat = CGFloat(AppConfig.shared.value(for: "music", key: "expanded_min_width", default: 320.0))
    }
    
    var id: String = "com.notchdock.music"
    var displayName: String = "Music"
    var iconName: String = "music.note"
    var isPremium: Bool = false
    var productID: String? = nil
    var hasRequiredPermissions: Bool {
        // We return true if at least one source is not explicitly denied.
        // This allows the module to try and trigger a prompt on first use.
        return MusicViewModel.shared.musicAuth != .denied || MusicViewModel.shared.spotifyAuth != .denied
    }
    var isLive: Bool { MusicViewModel.shared.isPlaying }
    var expandedMinWidth: CGFloat { Constants.expandedMinWidth }
    var compactView: AnyView { AnyView(MusicCompactView()) }
    var expandedView: AnyView { AnyView(MusicExpandedView()) }
    var settingsView: AnyView { AnyView(MusicSettingsView()) }
}

extension NSImage {
    func dominantColor() -> Color? {
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let ciImage = CIImage(bitmapImageRep: bitmap) else { return nil }
        
        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: ciImage.extent)
        ])
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        var bitmapOutput = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: NSColorSpace.deviceRGB.cgColorSpace as Any])
        context.render(outputImage, toBitmap: &bitmapOutput, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let r = CGFloat(bitmapOutput[0]) / 255.0
        let g = CGFloat(bitmapOutput[1]) / 255.0
        let b = CGFloat(bitmapOutput[2]) / 255.0
        
        // Ensure we don't get absolute black/white which looks bad as an accent
        if (r + g + b) < 0.1 { return Color.gray }
        if (r + g + b) > 2.9 { return Color.white }
        
        // Increase saturation and brightness for a more "vibrant" accent color
        var h: CGFloat = 0, s: CGFloat = 0, br: CGFloat = 0, a: CGFloat = 0
        NSColor(red: r, green: g, blue: b, alpha: 1.0).getHue(&h, saturation: &s, brightness: &br, alpha: &a)
        
        // We want highly saturated, bright colors for the accent
        return Color(nsColor: NSColor(hue: h, saturation: max(s, 0.8), brightness: max(br, 0.8), alpha: 1.0))
    }
}
