//
//  ColorTheme.swift
//  ppp
//
//  Created by Kiro on 2025-01-22.
//

import SwiftUI

// MARK: - Color Theme Extension with Dark Mode Support
extension Color {
    // Custom color palette (adaptive)
    static var softPink: Color {
        Color(light: Color(hex: "#FFB6B9"), dark: Color(hex: "#FFB3BA"))
    }
    
    static var softPeach: Color {
        Color(light: Color(hex: "#FAE3D9"), dark: Color(hex: "#4A4A4C"))
    }
    
    static var softMint: Color {
        Color(light: Color(hex: "#BBDED6"), dark: Color(hex: "#A8E6CF"))
    }
    
    static var softTeal: Color {
        Color(light: Color(hex: "#61C0BF"), dark: Color(hex: "#5DD3CE"))
    }
    
    // Semantic colors based on the palette (adaptive)
    static var primaryAccent: Color {
        softTeal
    }
    
    static var secondaryAccent: Color {
        softMint
    }
    
    static var backgroundPrimary: Color {
        Color(light: Color(hex: "#FAE3D9"), dark: Color(hex: "#1C1C1E"))
    }
    
    static var backgroundSecondary: Color {
        Color(light: Color.white, dark: Color(hex: "#2C2C2E"))
    }
    
    static var cardBackground: Color {
        Color(light: Color.white, dark: Color(hex: "#3A3A3C"))
    }
    
    static var textPrimary: Color {
        Color(light: Color.black.opacity(0.8), dark: Color.white.opacity(0.9))
    }
    
    static var textSecondary: Color {
        Color(light: Color.black.opacity(0.6), dark: Color.white.opacity(0.6))
    }
    
    static var textTertiary: Color {
        Color(light: Color.black.opacity(0.4), dark: Color.white.opacity(0.4))
    }
    
    // Status colors (adaptive)
    static var successColor: Color {
        Color(light: Color(hex: "#BBDED6"), dark: Color(hex: "#98D8AA"))
    }
    
    static var warningColor: Color {
        Color(light: Color(hex: "#FFB6B9"), dark: Color(hex: "#FFB3BA"))
    }
    
    static var infoColor: Color {
        Color(light: Color(hex: "#61C0BF"), dark: Color(hex: "#5DD3CE"))
    }
    
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
    
    // Helper initializer for light/dark mode colors
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
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