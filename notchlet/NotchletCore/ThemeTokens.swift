import SwiftUI

struct ThemeTokens {
    // Geometry
    static let cornerRadius: CGFloat = 16
    static let islandHeight: CGFloat = 34
    static let islandWidth: CGFloat = 190 // Matches physical notch exactly
    static let expandedIslandWidth: CGFloat = 700 // Wide enough to span across the physical notch
    
    // Colors & Materials
    static let glassMaterial = Material.ultraThinMaterial
    static let accentColor = Color(red: 85/255, green: 107/255, blue: 47/255) // Darker olive
    static let backgroundColor = Color(red: 12/255, green: 12/255, blue: 12/255) // #141414
    static let outlineColor = Color.white.opacity(0.05) // Made visible
    static let primaryText = Color(red: 219/255, green: 219/255, blue: 219/255) // #dbdbdb
    static let secondaryText = Color(red: 140/255, green: 140/255, blue: 140/255) // #8c8c8c (Visible gray for dark mode)
    
    // Typography
    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
    
    // Motion
    struct Spring {
        // Snappy, Apple-like spring curves
        static let standard = Animation.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.1)
        static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0.1)
    }
}
