import SwiftUI

struct TimerModule: NotchletExtension {
    var id: String = "com.notchlet.timer"
    var displayName: String = "Timer"
    var iconName: String = "timer"
    
    var isPremium: Bool = false
    var productID: String? = nil
    var hasRequiredPermissions: Bool = true
    
    // Using a structural wrapper to maintain the AnyView return type
    // while keeping state in Phase 2
    var compactView: AnyView {
        AnyView(
            HStack(spacing: 6) {
                Image(systemName: iconName)
                Text("25:00").font(.system(.body, design: .monospaced))
            }
        )
    }
    
    var expandedView: AnyView {
        AnyView(
            HStack(alignment: .center) {
                Text("25:00")
                    .font(.system(size: 36, weight: .medium, design: .monospaced))
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(ThemeTokens.primaryText)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {}) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(ThemeTokens.secondaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        )
    }
}
