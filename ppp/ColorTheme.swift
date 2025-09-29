//
//  ColorTheme.swift
//  ppp
//
//  Created by Kiro on 2025-01-22.
//

import SwiftUI

// MARK: - Color Theme Extension
extension Color {
    // Custom color palette
    static let softPink = Color(hex: "#FFB6B9")
    static let softPeach = Color(hex: "#FAE3D9")
    static let softMint = Color(hex: "#BBDED6")
    static let softTeal = Color(hex: "#61C0BF")
    
    // Semantic colors based on the palette
    static let primaryAccent = softTeal
    static let secondaryAccent = softMint
    static let backgroundPrimary = softPeach
    static let backgroundSecondary = Color.white
    static let cardBackground = Color.white
    static let textPrimary = Color.black.opacity(0.8)
    static let textSecondary = Color.black.opacity(0.6)
    static let textTertiary = Color.black.opacity(0.4)
    
    // Status colors
    static let successColor = softMint
    static let warningColor = softPink
    static let infoColor = softTeal
    
    // Initialize color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Neumorphism Style Modifiers
struct NeumorphismStyle: ViewModifier {
    var isPressed: Bool = false
    var cornerRadius: CGFloat = 12
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.cardBackground)
                    .shadow(
                        color: Color.black.opacity(isPressed ? 0.1 : 0.15),
                        radius: isPressed ? 2 : 8,
                        x: isPressed ? 1 : 4,
                        y: isPressed ? 1 : 4
                    )
                    .shadow(
                        color: Color.white.opacity(0.8),
                        radius: isPressed ? 1 : 4,
                        x: isPressed ? -1 : -2,
                        y: isPressed ? -1 : -2
                    )
            )
    }
}

struct SoftButtonStyle: ButtonStyle {
    var color: Color = .primaryAccent
    var cornerRadius: CGFloat = 12
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(configuration.isPressed ? 0.8 : 1.0),
                                color.opacity(configuration.isPressed ? 0.6 : 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: color.opacity(0.3),
                        radius: configuration.isPressed ? 2 : 6,
                        x: 0,
                        y: configuration.isPressed ? 1 : 3
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func neumorphism(isPressed: Bool = false, cornerRadius: CGFloat = 12) -> some View {
        self.modifier(NeumorphismStyle(isPressed: isPressed, cornerRadius: cornerRadius))
    }
    
    func softButton(color: Color = .primaryAccent, cornerRadius: CGFloat = 12) -> some View {
        self.buttonStyle(SoftButtonStyle(color: color, cornerRadius: cornerRadius))
    }
}