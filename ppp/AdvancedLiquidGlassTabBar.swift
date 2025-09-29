import SwiftUI

struct AdvancedLiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    @State private var dragOffset: CGSize = .zero
    @State private var isFloating = true
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    AdvancedTabBarButton(
                        tab: tabs[index],
                        isSelected: selectedTab == index,
                        action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedTab = index
                            }
                        }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Liquid glass background with dynamic blur
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.ultraThinMaterial)
                    
                    // Animated gradient overlay
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            AngularGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.blue.opacity(0.1),
                                    Color.purple.opacity(0.1),
                                    Color.white.opacity(0.2)
                                ],
                                center: .center,
                                angle: .degrees(Double(selectedTab) * 72)
                            )
                        )
                        .animation(.easeInOut(duration: 0.8), value: selectedTab)
                    
                    // Liquid border effect
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2),
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                    
                    // Inner glow
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                        .padding(2)
                }
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 30,
                    x: 0,
                    y: 20
                )
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 10,
                    x: 0,
                    y: 5
                )
            )
            .offset(dragOffset)
            .scaleEffect(isFloating ? 1.0 : 0.95)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFloating)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = CGSize(
                            width: min(max(value.translation.width, -50), 50),
                            height: min(max(value.translation.height, -20), 20)
                        )
                        isFloating = false
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            dragOffset = .zero
                            isFloating = true
                        }
                    }
            )
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height - 60
            )
        }
    }
}

struct AdvancedTabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    @State private var pulseScale: CGFloat = 1.0
    
    // Check if this is the add button (plus icon)
    private var isAddButton: Bool {
        tab.icon == "plus"
    }
    
    var body: some View {
        Button(action: {
            // Enhanced haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: isAddButton ? .heavy : .medium)
            impactFeedback.impactOccurred()
            
            // Pulse animation
            withAnimation(.easeOut(duration: 0.1)) {
                pulseScale = isAddButton ? 1.3 : 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.2)) {
                    pulseScale = 1.0
                }
            }
            
            action()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    // Special styling for add button
                    if isAddButton {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue,
                                        Color.purple,
                                        Color.pink
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: isSelected ? 56 : 50, height: isSelected ? 56 : 50)
                            .overlay(
                                Circle()
                                    .stroke(
                                        Color.white.opacity(0.8),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(
                                color: Color.blue.opacity(0.4),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                            .shadow(
                                color: Color.purple.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
                    } else {
                        // Liquid background for selected state (regular tabs)
                        if isSelected {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.blue.opacity(0.4),
                                            Color.purple.opacity(0.3),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 5,
                                        endRadius: 25
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.blue.opacity(0.3),
                                                    Color.purple.opacity(0.3),
                                                    Color.white.opacity(0.6)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .scaleEffect(isSelected ? 1.0 : 0.1)
                                .opacity(isSelected ? 1.0 : 0.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
                        }
                    }
                    
                    // Icon with liquid effect
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: isAddButton ? 24 : 22, weight: isAddButton ? .bold : (isSelected ? .bold : .medium)))
                        .foregroundStyle(
                            isAddButton ?
                            LinearGradient(
                                colors: [Color.white],
                                startPoint: .center,
                                endPoint: .center
                            ) :
                            (isSelected ?
                            LinearGradient(
                                colors: [
                                    Color.blue,
                                    Color.purple,
                                    Color.pink
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.primary.opacity(0.7)],
                                startPoint: .center,
                                endPoint: .center
                            ))
                        )
                        .scaleEffect(isSelected ? (isAddButton ? 1.1 : 1.2) : 1.0)
                        .scaleEffect(pulseScale)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
                        .shadow(
                            color: isSelected ? (isAddButton ? Color.white.opacity(0.5) : Color.blue.opacity(0.3)) : Color.clear,
                            radius: isSelected ? 8 : 0
                        )
                }
                
                // Animated label
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(
                        isAddButton ?
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        (isSelected ?
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.primary.opacity(0.7)],
                            startPoint: .center,
                            endPoint: .center
                        ))
                    )
                    .scaleEffect(isSelected ? 1.1 : (isAddButton ? 1.05 : 1.0))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.85 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Preview
struct AdvancedLiquidGlassTabBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            AdvancedLiquidGlassTabBar(
                selectedTab: .constant(0),
                tabs: [
                    TabItem(title: "首页", icon: "house", selectedIcon: "house.fill"),
                    TabItem(title: "项目", icon: "folder", selectedIcon: "folder.fill"),
                    TabItem(title: "添加", icon: "plus", selectedIcon: "plus.circle.fill"),
                    TabItem(title: "团队", icon: "person.2", selectedIcon: "person.2.fill"),
                    TabItem(title: "设置", icon: "gearshape", selectedIcon: "gearshape.fill")
                ]
            )
        }
    }
}