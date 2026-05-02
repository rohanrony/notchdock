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
    
    /// Distributes `orderedExtensions` into left and right icon arrays.
    ///
    /// - Slots 1–5   → left side (L→R, closest to notch last)
    /// - Slots 6–10  → right side, filling outward from notch (so slot 6 is
    ///                  closest to notch on the right, slot 10 is farthest right)
    /// - Slots 11+   → alternate: odd slot → left (extending further left),
    ///                  even slot → right (extending further right)
    ///
    /// `rightIcons` is returned in display order: index 0 = closest to notch.
    func distributeIcons(_ extensions: [any NotchletExtension]) -> (left: [any NotchletExtension], right: [any NotchletExtension]) {
        var left: [any NotchletExtension] = []
        var right: [any NotchletExtension] = []
        
        for (index, ext) in extensions.enumerated() {
            let slot = index + 1  // 1-based
            if slot <= 5 {
                // First 5 go to the left side
                left.append(ext)
            } else if slot <= 10 {
                // Slots 6-10: fill right side from notch outward.
                // Slot 6 = closest to notch (inserted at front), slot 10 = farthest right.
                // We insert at index (slot - 6) to build [slot6, slot7, slot8, slot9, slot10]
                // where index 0 is closest to notch.
                right.append(ext)
            } else {
                // Slot 11+: alternate between left and right.
                // Odd slots (11, 13, …) → left; even slots (12, 14, …) → right.
                if slot % 2 == 1 {
                    left.append(ext)
                } else {
                    right.append(ext)
                }
            }
        }
        
        return (left, right)
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
                .frame(width: 24, height: 24)
                .background(appState.activeExtensionID == ext.id ? Color.white.opacity(0.15) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    var expandedContent: some View {
        let orderedExtensions = appState.extensionOrder.compactMap { id in
            appState.registry.availableExtensions.first(where: { $0.id == id })
        }.filter { appState.enabledExtensionIDs.contains($0.id) }
        
        let (leftIcons, rightIcons) = distributeIcons(orderedExtensions)
        
        // Per-icon slot width: 24pt icon + 8pt spacing = 32pt; leading/trailing 16pt padding each side
        let iconSlotWidth: CGFloat = 32
        let barPadding: CGFloat = 16
        let fixedRightIcons: CGFloat = 2  // pin + gear always present
        let leftBarWidth  = barPadding + CGFloat(leftIcons.count)  * iconSlotWidth
        let rightBarWidth = barPadding + (CGFloat(rightIcons.count) + fixedRightIcons) * iconSlotWidth
        
        // Minimum gap to straddle the physical notch (notch width + 8pt breathing room each side)
        let notchGap = appState.detectedNotchWidth + 16
        
        // Active module's required content width
        let activeMinWidth: CGFloat = {
            if let activeId = appState.activeExtensionID,
               let ext = appState.registry.availableExtensions.first(where: { $0.id == activeId }) {
                return ext.expandedMinWidth
            }
            return 0
        }()
        
        // Total desired tray width, capped at the global maximum
        let trayWidth = min(
            leftBarWidth + notchGap + rightBarWidth + activeMinWidth,
            ThemeTokens.expandedIslandWidth
        )
        
        return VStack(spacing: 8) {
            // Top Section: Fits exactly in the menu bar height
            HStack(spacing: 0) {
                // Left side: Module icons (slots 1–5, then 11, 13, … extending outward)
                HStack(spacing: 8) {
                    ForEach(Array(leftIcons.enumerated()), id: \.element.id) { _, ext in
                        moduleIconButton(ext: ext)
                    }
                }
                .padding(.leading, 16)
                
                // Hardware Notch Spacer — minLength keeps icons from overlapping the notch;
                // the outer frame's minWidth (set per active module) drives the actual tray width.
                // We align the center of this spacer to the .notchCenter guide to ensure symmetry.
                Spacer(minLength: notchGap)
                    .alignmentGuide(.notchCenter) { d in d[HorizontalAlignment.center] }
                
                // Right side: Module icons + pin + gear
                // rightIcons[0] is closest to notch → rendered leftmost in this HStack
                HStack(spacing: 8) {
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
                        Image(systemName: appState.isPinned ? "pin.circle.fill" : "pin")
                            .font(.system(size: appState.isPinned ? 16 : 13, weight: .medium))
                            .foregroundColor(appState.isPinned
                                ? Color(hue: 0.08, saturation: 0.75, brightness: 1.0)  // warm amber
                                : Color.gray
                            )
                            .frame(width: 24, height: 24)
                            .background(appState.isPinned ? Color(hue: 0.08, saturation: 0.75, brightness: 1.0).opacity(0.12) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help(appState.isPinned ? "Unpin – close on mouse-out" : "Pin open")
                    .animation(ThemeTokens.Spring.standard, value: appState.isPinned)
                    
                    // Settings button – opened programmatically (SettingsLink doesn't work
                    // inside a nonactivating NSPanel)
                    Button(action: {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                        NSApp.activate(ignoringOtherApps: true)
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.gray)
                            .frame(width: 24, height: 24)
                            .background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help("Settings")
                }
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
            
            Spacer(minLength: 0)
        }
        .frame(minWidth: trayWidth)  // Shrink/grow tray to match active module's needs
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
            removal: .opacity.animation(.easeIn(duration: 0.1))
        ))
    }
}
