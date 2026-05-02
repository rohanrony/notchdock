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
    
    var expandedContent: some View {
        VStack(spacing: 8) {
            // Top Section: Fits exactly in the menu bar height
            HStack(spacing: 0) {
                // Left side: Module switcher
                HStack(spacing: 8) {
                    let orderedExtensions = appState.extensionOrder.compactMap { id in
                        appState.registry.availableExtensions.first(where: { $0.id == id })
                    }.filter { appState.enabledExtensionIDs.contains($0.id) }
                    
                    ForEach(orderedExtensions, id: \.id) { ext in
                        Button(action: {
                            withAnimation {
                                appState.activeExtensionID = ext.id
                            }
                        }) {
                            Image(systemName: ext.iconName)
                                .font(.system(size: 13, weight: .medium)) // Menu bar size
                                .foregroundColor(appState.activeExtensionID == ext.id ? ThemeTokens.primaryText : Color.gray)
                                .frame(width: 24, height: 24)
                                .background(appState.activeExtensionID == ext.id ? Color.white.opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 16)
                
                // Hardware Notch Spacer
                Spacer(minLength: 320)
                
                // Right side: Settings & actions
                HStack(spacing: 8) {
                    SettingsLink {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13, weight: .medium)) // Menu bar size
                            .foregroundColor(Color.gray)
                            .frame(width: 24, height: 24)
                            .background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
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
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
            removal: .opacity.animation(.easeIn(duration: 0.1))
        ))
    }
}
