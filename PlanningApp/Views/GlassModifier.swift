import SwiftUI

// MARK: - Liquid Glass Design System
// iOS 26 introduced "Liquid Glass" (glassEffect modifier)
// This file provides a unified .glassCard() modifier that:
//   - Uses glassEffect() on iOS 26+
//   - Falls back to a clean frosted material card on iOS 18

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.clear)
                        .glassEffect(in: .rect(cornerRadius: cornerRadius))
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            content
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
        }
    }
}

extension View {
    /// Apply Liquid Glass (iOS 26+) or a clean card background (iOS 18+)
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Colored Glass (for accent surfaces like stat cards)
// On iOS 26: tinted glass. On iOS 18: light tinted background.
struct TintedGlassModifier: ViewModifier {
    var color: Color
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(color.opacity(0.15))
                        .glassEffect(in: .rect(cornerRadius: cornerRadius))
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            content
                .background(
                    LinearGradient(
                        colors: [color.opacity(0.8), color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

extension View {
    /// Apply colored Liquid Glass (iOS 26+) or a colored gradient card (iOS 18+)
    func tintedGlass(color: Color, cornerRadius: CGFloat = 16) -> some View {
        modifier(TintedGlassModifier(color: color, cornerRadius: cornerRadius))
    }
}
