import SwiftUI

struct SectionCard<Content: View>: View {
    let title: String?
    let subtitle: String?
    let content: Content
    
    init(title: String? = nil, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(ThemeTokens.primaryText)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(ThemeTokens.secondaryText)
                    }
                }
                .padding(.horizontal, 4)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(ThemeTokens.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeTokens.cardOutline, lineWidth: 1)
            )
        }
    }
}

struct SettingsRow<Content: View>: View {
    let label: String
    let icon: String?
    let content: Content
    
    init(_ label: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.label = label
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(ThemeTokens.accentColor)
                    .frame(width: 20)
            }
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(ThemeTokens.primaryText)
            
            Spacer()
            
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
