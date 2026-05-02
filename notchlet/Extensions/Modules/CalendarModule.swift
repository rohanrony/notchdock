import SwiftUI

struct CalendarModule: NotchletExtension {
    var id: String = "com.notchlet.calendar"
    var displayName: String = "Calendar"
    var iconName: String = "calendar"
    
    var isPremium: Bool = false
    var productID: String? = nil
    var hasRequiredPermissions: Bool = true // Stub for EventKit check
    
    var compactView: AnyView {
        AnyView(
            HStack(spacing: 6) {
                Image(systemName: iconName)
                Text("15m").font(.system(.body, design: .rounded).bold())
            }
        )
    }
    
    var expandedView: AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(ThemeTokens.secondaryText)
                    Spacer()
                    Text("In 15m")
                        .foregroundColor(.secondary)
                }
                
                Text("Product Sync")
                    .font(.title3.bold())
                
                Button(action: {
                    // Logic to join URL
                }) {
                    HStack {
                        Image(systemName: "video.fill")
                        Text("Join Zoom")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        )
    }
}
