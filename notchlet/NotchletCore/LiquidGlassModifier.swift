import SwiftUI

struct LiquidGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            // Deep, multi-layered shadow for floating effect
            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            // Premium glass rim highlight
            .overlay(
                RoundedRectangle(cornerRadius: ThemeTokens.cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.15)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
    }
}
