import SwiftUI

struct ClaudeModule: NotchletExtension {
    var id: String = "com.notchlet.claude"
    var displayName: String = "Claude"
    var iconName: String = "sparkles"
    
    var isPremium: Bool = false
    var productID: String? = nil
    var hasRequiredPermissions: Bool = true
    var isApiKeyConfigured: Bool = false // Toggle this to test the API key warning
    
    var compactView: AnyView {
        AnyView(Image(systemName: iconName))
    }
    
    var expandedView: AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 12) {
                // Static UI for Phase 2
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color.black.opacity(0.1))
                    .overlay(
                        HStack {
                            Text("Message...")
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 12)
                    )
                    .frame(height: 40)
                
                if !isApiKeyConfigured {
                    HStack {
                        Image(systemName: "key.fill")
                            .font(.caption)
                        Text("API Key not configured")
                            .font(.caption)
                    }
                    .foregroundColor(Color(red: 0.7, green: 0.1, blue: 0.1)) // Dark red
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        )
    }
}
