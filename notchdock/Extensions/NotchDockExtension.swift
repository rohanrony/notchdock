import SwiftUI

protocol NotchDockExtension: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var iconName: String { get }
    
    // Monetization
    var isPremium: Bool { get }
    var productID: String? { get }
    
    // System Access
    var hasRequiredPermissions: Bool { get }
    
    // Logic
    var hasCompactView: Bool { get }
    var isLive: Bool { get }
    
    // Views
    @ViewBuilder var compactView: AnyView { get }
    @ViewBuilder var expandedView: AnyView { get }
    @ViewBuilder var settingsView: AnyView { get }
    
    /// Minimum width (pts) the expanded content needs to render correctly.
    /// Return 0 to let the tray shrink to fit the icon bar only.
    var expandedMinWidth: CGFloat { get }
}

extension NotchDockExtension {
    var hasCompactView: Bool { true }
    var isLive: Bool { false }
    var expandedMinWidth: CGFloat { 0 }
    
    var settingsView: AnyView {
        AnyView(
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 40))
                    .foregroundColor(ThemeTokens.accentColor)
                Text(displayName)
                    .font(.headline)
                Text("No specific settings for this module.")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    func safeExpandedView() -> AnyView {
        if !hasRequiredPermissions {
            return AnyView(
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    Text("Access Required")
                        .font(.headline)
                    Text("Please grant permissions in System Settings to use this module.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            )
        } else {
            return expandedView
        }
    }
}
