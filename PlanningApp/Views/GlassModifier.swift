import SwiftUI

// MARK: - Glass Design System
// Provides a unified .glassCard() modifier that creates a frosted glass appearance
// using SwiftUI Material effects (available since iOS 15).
//
// When Xcode 17 (iOS 26 SDK) becomes available on GitHub Actions runners,
// this can be upgraded to use the native .glassEffect() API.

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

extension View {
    /// Apply a frosted glass card background with rounded corners and subtle shadow.
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Tinted Glass (for accent-colored surfaces)
struct TintedGlassModifier: ViewModifier {
    var color: Color
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(color.opacity(0.12))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: color.opacity(0.15), radius: 10, x: 0, y: 4)
    }
}

extension View {
    /// Apply a tinted frosted glass card background.
    func tintedGlass(color: Color, cornerRadius: CGFloat = 16) -> some View {
        modifier(TintedGlassModifier(color: color, cornerRadius: cornerRadius))
    }
}
