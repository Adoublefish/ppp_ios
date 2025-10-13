import SwiftUI

// MARK: - Neumorphic Tab Bar
struct NeumorphicTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                NeumorphicTabButton(
                    tab: tabs[index],
                    isSelected: selectedTab == index,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            ZStack {
                // Neumorphic background
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.neuBackground)
                
                // Subtle inner shadow effect (adaptive for dark mode)
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(light: Color.black.opacity(0.05), dark: Color.white.opacity(0.02)),
                                Color.clear,
                                Color(light: Color.white.opacity(0.1), dark: Color.black.opacity(0.3))
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Soft border (adaptive)
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(light: Color.white.opacity(0.5), dark: Color.white.opacity(0.1)),
                                Color.clear,
                                Color(light: Color.black.opacity(0.1), dark: Color.black.opacity(0.4))
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: .neuShadowDark, radius: 12, x: 8, y: 8)
            .shadow(color: .neuShadowLight, radius: 12, x: -8, y: -8)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
            // Background that extends to bottom edge
            Rectangle()
                .fill(Color.neuBackground)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Neumorphic Tab Button
struct NeumorphicTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    // Check if this is the add button (plus icon)
    private var isAddButton: Bool {
        tab.icon == "plus"
    }
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: isAddButton ? .medium : .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    // Special neumorphic styling for add button
                    if isAddButton {
                        Circle()
                            .fill(Color.neuBackground)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.neuAccent.opacity(0.8),
                                                Color.neuAccent
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 46, height: 46)
                            )
                            .shadow(color: .neuShadowDark, radius: 6, x: 4, y: 4)
                            .shadow(color: .neuShadowLight, radius: 6, x: -4, y: -4)
                            .shadow(color: Color.neuAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                            .scaleEffect(isSelected ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    } else {
                        // Neumorphic circle for selected state (regular tabs)
                        if isSelected {
                            Circle()
                                .fill(Color.neuBackground)
                                .frame(width: 44, height: 44)
                                .shadow(color: .neuShadowDark, radius: 3, x: 3, y: 3)
                                .shadow(color: .neuShadowLight, radius: 3, x: -3, y: -3)
                                .overlay(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.neuAccent.opacity(0.2),
                                                    Color.neuAccent.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                )
                                .scaleEffect(isSelected ? 1.0 : 0.8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                        }
                    }
                    
                    // Icon
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: isAddButton ? 24 : 22, weight: isAddButton ? .bold : (isSelected ? .semibold : .medium)))
                        .foregroundColor(
                            isAddButton ? .white :
                            (isSelected ? .neuAccent : .neuTextSecondary)
                        )
                        .scaleEffect(isSelected ? (isAddButton ? 1.0 : 1.1) : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                }
                
                // Label
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(
                        isAddButton ? .neuAccent :
                        (isSelected ? .neuAccent : .neuTextSecondary)
                    )
                    .scaleEffect(isSelected ? 1.02 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Alternative Neumorphic Tab Bar with Inset Style
struct NeumorphicInsetTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<tabs.count, id: \.self) { index in
                NeumorphicInsetTabButton(
                    tab: tabs[index],
                    isSelected: selectedTab == index,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.neuBackground)
                .shadow(color: .neuShadowDark, radius: 10, x: 6, y: 6)
                .shadow(color: .neuShadowLight, radius: 10, x: -6, y: -6)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(Color.neuBackground)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Inset Tab Button
struct NeumorphicInsetTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    private var isAddButton: Bool {
        tab.icon == "plus"
    }
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        // Raised neumorphic pill for selected state
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.neuBackground)
                            .frame(height: 44)
                            .shadow(color: .neuShadowDark, radius: 4, x: 4, y: 4)
                            .shadow(color: .neuShadowLight, radius: 4, x: -4, y: -4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.neuAccent.opacity(0.15),
                                                Color.neuAccent.opacity(0.08)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                        
                        if isSelected {
                            Text(tab.title)
                                .font(.system(size: 12, weight: .semibold))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .foregroundColor(isSelected ? .neuAccent : .neuTextSecondary)
                }
                .frame(height: 44)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Preview
struct NeumorphicTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            NeumorphicTabBar(
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
        .background(Color.neuBackground)
        .ignoresSafeArea()
    }
}

