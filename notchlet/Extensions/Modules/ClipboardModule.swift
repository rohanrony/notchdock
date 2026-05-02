import SwiftUI

struct ClipboardModule: NotchletExtension {
    var id: String = "com.notchlet.clipboard"
    var displayName: String = "Clipboard"
    var iconName: String = "doc.on.clipboard"
    
    var isPremium: Bool = false
    var productID: String? = nil
    var hasRequiredPermissions: Bool = true
    
    var compactView: AnyView {
        AnyView(Image(systemName: iconName))
    }
    
    var expandedView: AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Items")
                    .font(.headline)
                    .foregroundColor(ThemeTokens.secondaryText)
                    .padding(.bottom, 4)
                
                ForEach(1...3, id: \.self) { i in
                    HStack {
                        Text("Copied snippet \(i)...")
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "doc.on.clipboard.fill")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        )
    }
}
