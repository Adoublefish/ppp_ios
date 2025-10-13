import SwiftUI

// MARK: - Neumorphic Color Extensions with Dark Mode Support
extension Color {
    // Neumorphic Base Colors (Adaptive for Light/Dark Mode)
    static var neuBackground: Color {
        Color(light: Color(hex: "#E8ECF0"), dark: Color(hex: "#2C2C2E"))
    }
    
    static var neuShadowDark: Color {
        Color(light: Color.black.opacity(0.2), dark: Color.black.opacity(0.6))
    }
    
    static var neuShadowLight: Color {
        Color(light: Color.white.opacity(0.7), dark: Color.white.opacity(0.05))
    }
    
    // Accent Colors (Brighter in Dark Mode)
    static var neuAccent: Color {
        Color(light: Color.softTeal, dark: Color(hex: "#5DD3CE"))
    }
    
    static var neuAccentLight: Color {
        Color(light: Color.softMint, dark: Color(hex: "#A8E6CF"))
    }
    
    static var neuWarning: Color {
        Color(light: Color.softPink, dark: Color(hex: "#FFB3BA"))
    }
    
    static var neuSuccess: Color {
        Color(light: Color.green.opacity(0.8), dark: Color(hex: "#98D8AA"))
    }
    
    // Text Colors (Adaptive)
    static var neuTextPrimary: Color {
        Color(light: Color.black.opacity(0.8), dark: Color.white.opacity(0.9))
    }
    
    static var neuTextSecondary: Color {
        Color(light: Color.black.opacity(0.5), dark: Color.white.opacity(0.6))
    }
    
    static var neuTextTertiary: Color {
        Color(light: Color.black.opacity(0.3), dark: Color.white.opacity(0.3))
    }
    
    // Soft Pastel Colors (Adjusted for Dark Mode)
    static var neuPastelPeach: Color {
        Color(light: Color.softPeach, dark: Color(hex: "#FFB88C"))
    }
    
    static var neuPastelMint: Color {
        Color(light: Color.softMint, dark: Color(hex: "#A8E6CF"))
    }
    
    static var neuPastelTeal: Color {
        Color(light: Color.softTeal, dark: Color(hex: "#5DD3CE"))
    }
    
    static var neuPastelPink: Color {
        Color(light: Color.softPink, dark: Color(hex: "#FFB3BA"))
    }
    
    static var neuPastelGreen: Color {
        Color(light: Color(hex: "#C8E6C9"), dark: Color(hex: "#98D8AA"))
    }
    
    static var neuPastelOrange: Color {
        Color(light: Color(hex: "#FFE0B2"), dark: Color(hex: "#FFD5A0"))
    }
}

// MARK: - Neumorphic Button Style
struct NeumorphicButtonStyle: ButtonStyle {
    var color: Color = .neuBackground
    var textColor: Color = .neuTextPrimary
    var isInset: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color)
                    
                    if configuration.isPressed {
                        // Pressed state - inset look
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color)
                            .shadow(color: .neuShadowDark, radius: 3, x: 2, y: 2)
                            .shadow(color: .neuShadowLight, radius: 3, x: -2, y: -2)
                            .blendMode(.overlay)
                    } else if isInset {
                        // Inset/Recessed look
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color)
                            .shadow(color: .neuShadowDark, radius: 4, x: 3, y: 3)
                            .shadow(color: .neuShadowLight, radius: 4, x: -3, y: -3)
                            .blendMode(.multiply)
                    } else {
                        // Raised/Embossed look (default)
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color)
                            .shadow(color: .neuShadowDark, radius: 6, x: 6, y: 6)
                            .shadow(color: .neuShadowLight, radius: 6, x: -6, y: -6)
                    }
                }
            )
            .foregroundColor(textColor)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Neumorphic Card Modifier
struct NeumorphicCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    var isInset: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.neuBackground)
                    
                    if isInset {
                        // Inset card
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.neuBackground)
                            .shadow(color: .neuShadowDark, radius: 5, x: 5, y: 5)
                            .shadow(color: .neuShadowLight, radius: 5, x: -5, y: -5)
                            .blendMode(.multiply)
                    } else {
                        // Raised card
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.neuBackground)
                            .shadow(color: .neuShadowDark, radius: 8, x: 8, y: 8)
                            .shadow(color: .neuShadowLight, radius: 8, x: -8, y: -8)
                    }
                }
            )
    }
}

// MARK: - Neumorphic Inset Modifier
struct NeumorphicInset: ViewModifier {
    var cornerRadius: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.neuBackground)
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.1),
                                    Color.clear,
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear,
                                    Color.black.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: .neuShadowDark, radius: 3, x: 2, y: 2)
                .shadow(color: .neuShadowLight, radius: 3, x: -2, y: -2)
            )
    }
}

// MARK: - Neumorphic Emboss Modifier
struct NeumorphicEmboss: ViewModifier {
    var cornerRadius: CGFloat = 16
    var isPressed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.neuBackground)
                    
                    if isPressed {
                        // Pressed state
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.15),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: isPressed ? .neuShadowDark : .neuShadowLight, radius: 4, x: isPressed ? 3 : -4, y: isPressed ? 3 : -4)
                .shadow(color: isPressed ? .neuShadowLight : .neuShadowDark, radius: 4, x: isPressed ? -3 : 4, y: isPressed ? -3 : 4)
            )
    }
}

// MARK: - Neumorphic Toggle Style
struct NeumorphicToggleStyle: ToggleStyle {
    var onColor: Color = .neuAccent
    var offColor: Color = .neuTextTertiary
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            ZStack {
                // Background track
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.neuBackground)
                    .frame(width: 54, height: 32)
                    .shadow(color: .neuShadowDark, radius: 3, x: 2, y: 2)
                    .shadow(color: .neuShadowLight, radius: 3, x: -2, y: -2)
                
                // Toggle circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                configuration.isOn ? onColor : offColor,
                                configuration.isOn ? onColor.opacity(0.8) : offColor.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .shadow(color: .neuShadowDark, radius: 3, x: 3, y: 3)
                    .shadow(color: .neuShadowLight, radius: 3, x: -1, y: -1)
                    .offset(x: configuration.isOn ? 11 : -11)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

// MARK: - Neumorphic Icon Button
struct NeumorphicIconButton: View {
    var icon: String
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    var color: Color = .neuBackground
    var iconColor: Color = .neuTextPrimary
    var action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: size, height: size)
                .background(
                    ZStack {
                        Circle()
                            .fill(color)
                        
                        Circle()
                            .fill(color)
                            .shadow(color: isPressed ? .neuShadowDark : .neuShadowLight, radius: 4, x: isPressed ? 3 : -4, y: isPressed ? 3 : -4)
                            .shadow(color: isPressed ? .neuShadowLight : .neuShadowDark, radius: 4, x: isPressed ? -3 : 4, y: isPressed ? -3 : 4)
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Neumorphic Pill Button
struct NeumorphicPillButton: View {
    var title: String
    var icon: String? = nil
    var color: Color = .neuAccent
    var isSelected: Bool = false
    var action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .neuTextPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    Capsule()
                        .fill(isSelected ? color : Color.neuBackground)
                    
                    if !isSelected {
                        Capsule()
                            .fill(Color.neuBackground)
                            .shadow(color: isPressed ? .neuShadowDark : .neuShadowLight, radius: 3, x: isPressed ? 2 : -3, y: isPressed ? 2 : -3)
                            .shadow(color: isPressed ? .neuShadowLight : .neuShadowDark, radius: 3, x: isPressed ? -2 : 3, y: isPressed ? -2 : 3)
                    } else {
                        Capsule()
                            .fill(color)
                            .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - View Extensions
extension View {
    func neumorphicButton(color: Color = .neuBackground, textColor: Color = .neuTextPrimary, isInset: Bool = false) -> some View {
        self.buttonStyle(NeumorphicButtonStyle(color: color, textColor: textColor, isInset: isInset))
    }
    
    func neumorphicCard(cornerRadius: CGFloat = 20, padding: CGFloat = 16, isInset: Bool = false) -> some View {
        self.modifier(NeumorphicCard(cornerRadius: cornerRadius, padding: padding, isInset: isInset))
    }
    
    func neumorphicInset(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(NeumorphicInset(cornerRadius: cornerRadius))
    }
    
    func neumorphicEmboss(cornerRadius: CGFloat = 16, isPressed: Bool = false) -> some View {
        self.modifier(NeumorphicEmboss(cornerRadius: cornerRadius, isPressed: isPressed))
    }
}

// MARK: - Neumorphic Progress View
struct NeumorphicProgressView: View {
    var progress: Double
    var color: Color = .neuAccent
    var height: CGFloat = 12
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.neuBackground)
                    .frame(height: height)
                    .neumorphicInset(cornerRadius: height / 2)
                
                // Progress fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: height - 4)
                    .shadow(color: color.opacity(0.3), radius: 3, x: 0, y: 2)
                    .padding(.leading, 2)
            }
        }
        .frame(height: height)
    }
}

