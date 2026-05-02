import SwiftUI

extension HorizontalAlignment {
    private enum NotchCenterAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[HorizontalAlignment.center]
        }
    }
    static let notchCenter = HorizontalAlignment(NotchCenterAlignment.self)
}

extension Alignment {
    static let notchCentered = Alignment(horizontal: .notchCenter, vertical: .top)
}

struct IslandView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // Spring animations defined in spec
    var expandAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : ThemeTokens.Spring.bouncy
    }
    var collapseAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : ThemeTokens.Spring.standard
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Anchor to the top
            Spacer().frame(height: 0)
            
            ZStack {
                // Solid #050505 background with 3D feel
                let currentRadius = appState.isExpanded ? 40 : ThemeTokens.cornerRadius
                NotchShape(cornerRadius: currentRadius)
                    .fill(ThemeTokens.backgroundColor)
                    // Multi-layered shadows for 3D floating tray
                    .shadow(color: appState.isExpanded ? Color.black.opacity(0.5) : .clear, radius: 15, x: 0, y: 10)
                    .shadow(color: appState.isExpanded ? Color.black.opacity(0.3) : .clear, radius: 3, x: 0, y: 2)
                
                // Content
                VStack {
                    if appState.isExpanded {
                        expandedContent
                    } else {
                        compactContent
                    }
                }
                // Padding to avoid the blend curves on the edges
                .padding(.horizontal, 16)
            }
            .frame(
                minWidth: appState.isExpanded ? 0 : appState.detectedNotchWidth,
                maxWidth: appState.isExpanded ? ThemeTokens.expandedIslandWidth : nil,
                minHeight: appState.detectedMenuBarHeight
            )
            .fixedSize(horizontal: true, vertical: true)
            .environment(\.colorScheme, .dark)
            .onHover { isHovering in
                // Pinned: always stay expanded; only collapse on hover-out when not pinned
                guard !appState.isPinned else { return }
                withAnimation(isHovering ? expandAnimation : collapseAnimation) {
                    appState.isExpanded = isHovering
                }
            }
            
            Spacer() // Push to top
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .notchCentered)
    }
    
    // MARK: - Subviews
    
    var compactContent: some View {
        HStack(spacing: 0) {
            if let activeId = appState.activeExtensionID,
               let activeExt = appState.registry.availableExtensions.first(where: { $0.id == activeId }) {
                activeExt.compactView
            } else {
                Spacer(minLength: 190)
            }
        }
        .frame(height: appState.detectedMenuBarHeight)
        .padding(.horizontal, 6)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9, anchor: .top).combined(with: .opacity),
            removal: .opacity.animation(.easeIn(duration: 0.1))
        ))
    }
    
    /// Distributes `orderedExtensions` into left and right arrays and calculates the symmetric slot count.
    ///
    /// Symmetry Rules:
    /// - Right side always has 2 fixed icons (Pin + Gear).
    /// - 1-2 Modules: Left fills [M1, M2]. Right is empty [Pin, Gear]. (2 slots each side)
    /// - 3 Modules: Left [M1, M2, M3]. Right has 1 empty module slot [_, Pin, Gear]. (3 slots each)
    /// - 4 Modules: Left [M1, M2, M3]. Right gets 1st module [M4, Pin, Gear]. (3 slots each)
    /// - 5 Modules: Left [M1, M2, M3, M5]. Right has [_, M4, Pin, Gear]. (4 slots each)
    /// - 6 Modules: Left [M1, M2, M3, M5]. Right has [M6, M4, Pin, Gear]. (4 slots each)
    func distributeIcons(_ extensions: [any NotchletExtension]) -> (left: [any NotchletExtension], right: [any NotchletExtension], numSlots: Int) {
        let n = extensions.count
        
        // We want a logical left-to-right flow: [M1, M2, M3] <GAP> [M4, M5, Pin, Gear]
        // Left side has L modules. Right side has R modules + 2 fixed icons (Pin/Gear).
        // The user wants Left > Right when total icons (n + 2) is odd.
        // L + R = n. Total Left = L. Total Right = R + 2.
        // We want L >= R + 2  => L >= (n - L) + 2 => 2L >= n + 2 => L >= (n+2)/2.
        // To favor the left when odd, we use ceil((n+2)/2), which is (n + 3) / 2 in integer math.
        let numLeft = (n + 3) / 2
        
        var left: [any NotchletExtension] = []
        var right: [any NotchletExtension] = []
        
        for (index, ext) in extensions.enumerated() {
            if index < numLeft {
                left.append(ext)
            } else {
                right.append(ext)
            }
        }
        
        // numSlots is the capacity of each side to ensure the tray background remains symmetric.
        let numSlots = max(2, numLeft, right.count + 2)
        
        return (left, right, numSlots)
    }
    
    func moduleIconButton(ext: any NotchletExtension) -> some View {
        Button(action: {
            withAnimation {
                appState.activeExtensionID = ext.id
            }
        }) {
            Image(systemName: ext.iconName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(appState.activeExtensionID == ext.id ? ThemeTokens.primaryText : Color.gray)
                .frame(width: 22, height: 22)
                .background(appState.activeExtensionID == ext.id ? Color.white.opacity(0.15) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    var expandedContent: some View {
        let orderedExtensions = appState.extensionOrder.compactMap { id in
            appState.registry.availableExtensions.first(where: { $0.id == id })
        }.filter { appState.enabledExtensionIDs.contains($0.id) }
        
        let (leftIcons, rightIcons, numSlots) = distributeIcons(orderedExtensions)
        
        // Per-icon slot width (icon + spacing); leading/trailing padding each side
        let iconSlotWidth: CGFloat = AppConfig.App.iconSlotWidth
        let barPadding: CGFloat = AppConfig.App.barPadding
        
        // Symmetric bar width based on number of slots
        let symmetricBarWidth = barPadding + CGFloat(numSlots) * iconSlotWidth
        
        // Minimum gap to straddle the physical notch (notch width + breathing room)
        let notchGap = appState.detectedNotchWidth + AppConfig.App.notchBreathingRoom
        
        // Active module's required content width
        let activeMinWidth: CGFloat = {
            if let activeId = appState.activeExtensionID,
               let ext = appState.registry.availableExtensions.first(where: { $0.id == activeId }) {
                return ext.expandedMinWidth
            }
            return 0
        }()
        
        // Total desired tray width is the maximum of the symmetric icon bars + notch or the content's required width
        let trayWidth = min(
            max(symmetricBarWidth * 2 + notchGap, activeMinWidth),
            ThemeTokens.expandedIslandWidth
        )
        
        return VStack(spacing: 8) {
            // Top Section: Fits exactly in the menu bar height
            HStack(spacing: 0) {
                // Left side: Module icons
                HStack(spacing: 6) {
                    ForEach(Array(leftIcons.enumerated()), id: \.element.id) { _, ext in
                        moduleIconButton(ext: ext)
                    }
                    Spacer(minLength: 0) // Push icons to the left, but stay within the symmetricBarWidth
                }
                .frame(width: symmetricBarWidth, alignment: .leading)
                .padding(.leading, 16)
                
                // Hardware Notch Spacer — centered via alignment guide
                Spacer(minLength: notchGap)
                    .alignmentGuide(.notchCenter) { d in d[HorizontalAlignment.center] }
                
                // Right side: Module icons + pin + gear
                HStack(spacing: 6) {
                    Spacer(minLength: 0) // Push icons to the right
                    
                    // Module icons assigned to the right side
                    ForEach(Array(rightIcons.enumerated()), id: \.element.id) { _, ext in
                        moduleIconButton(ext: ext)
                    }
                    
                    // Pin button: locks the notch open
                    Button(action: {
                        withAnimation(ThemeTokens.Spring.standard) {
                            appState.isPinned.toggle()
                            if appState.isPinned {
                                appState.isExpanded = true
                            }
                        }
                    }) {
                        Image(systemName: appState.isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(appState.isPinned
                                ? Color(hue: 0.08, saturation: 0.8, brightness: 1.0)  // warm amber
                                : ThemeTokens.secondaryText
                            )
                            .frame(width: 22, height: 22)
                            .background(appState.isPinned ? Color(hue: 0.08, saturation: 0.8, brightness: 1.0).opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help(appState.isPinned ? "Unpin – close on mouse-out" : "Pin open")
                    .animation(ThemeTokens.Spring.standard, value: appState.isPinned)
                    
                    // Settings button
                    SettingsLink {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(ThemeTokens.secondaryText)
                            .frame(width: 22, height: 22)
                            .background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help("Settings")


                }
                .frame(width: symmetricBarWidth, alignment: .trailing)
                .padding(.trailing, 16)
            }
            .frame(height: appState.detectedMenuBarHeight)
            
            // Middle Section: Active Module Title removed per user request
            
            // Bottom Section: Active Module Content
            if let activeId = appState.activeExtensionID,
               let activeExt = appState.registry.availableExtensions.first(where: { $0.id == activeId }) {
                activeExt.safeExpandedView()
                    // Modules supply their own internal padding; removing duplicate horizontal padding here
            } else {
                Text("No Active Module")
                    .font(ThemeTokens.font(size: 14))
                    .foregroundColor(ThemeTokens.secondaryText)
                    .padding()
            }
            
        }
        .frame(minWidth: trayWidth)  // Shrink/grow tray to match active module's needs
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
            removal: .opacity.animation(.easeIn(duration: 0.1))
        ))
    }
}
