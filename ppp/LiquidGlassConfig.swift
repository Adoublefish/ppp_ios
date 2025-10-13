import SwiftUI

// MARK: - Liquid Glass Configuration
struct LiquidGlassConfig {
    // Visual Properties
    static let cornerRadius: CGFloat = 28
    static let borderWidth: CGFloat = 1.5
    static let shadowRadius: CGFloat = 25
    static let shadowOffset: CGSize = CGSize(width: 0, height: 15)
    
    // Animation Properties
    static let springResponse: Double = 0.4
    static let springDamping: Double = 0.8
    static let pressAnimationDuration: Double = 0.1
    
    // Colors
    static let primaryGradient = LinearGradient(
        colors: [Color.softTeal, Color.softMint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.3),
            Color.white.opacity(0.1),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let borderGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.4),
            Color.white.opacity(0.1),
            Color.clear,
            Color.white.opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Haptic Feedback
    static func lightHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func mediumHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Glass Material Extension
extension Material {
    static var liquidGlass: Material {
        .ultraThinMaterial
    }
}

// MARK: - Animation Extensions
extension Animation {
    static var liquidSpring: Animation {
        .spring(
            response: LiquidGlassConfig.springResponse,
            dampingFraction: LiquidGlassConfig.springDamping
        )
    }
    
    static var liquidPress: Animation {
        .easeInOut(duration: LiquidGlassConfig.pressAnimationDuration)
    }
}

// MARK: - Color Extensions
extension Color {
    static var liquidPrimary: LinearGradient {
        LiquidGlassConfig.primaryGradient
    }
    
    static var liquidGlass: LinearGradient {
        LiquidGlassConfig.glassGradient
    }
    
    static var liquidBorder: LinearGradient {
        LiquidGlassConfig.borderGradient
    }
}