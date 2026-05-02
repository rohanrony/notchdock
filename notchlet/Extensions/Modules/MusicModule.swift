import SwiftUI

struct MusicModule: NotchletExtension {
    var id: String = "com.notchlet.music"
    var displayName: String = "Music"
    var iconName: String = "music.note"
    
    var isPremium: Bool = false
    var productID: String? = nil
    var hasRequiredPermissions: Bool = true // Stub for MediaRemote check
    
    var compactView: AnyView {
        AnyView(Image(systemName: iconName))
    }
    
    var expandedView: AnyView {
        AnyView(
            HStack(spacing: 16) {
                // Album Art Placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(Image(systemName: "music.quarternote.3").foregroundColor(.secondary))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lofi Beats")
                        .font(.headline)
                    Text("Chillhop Music")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        Image(systemName: "backward.fill")
                        Image(systemName: "pause.fill")
                        Image(systemName: "forward.fill")
                    }
                    .font(.title3)
                    .padding(.top, 4)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        )
    }
}
