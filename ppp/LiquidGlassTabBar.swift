import SwiftUI

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarButton(
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
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Main glass background
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                
                // Gradient overlay for depth
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.black.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Border highlight
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .shadow(
                color: Color.black.opacity(0.15),
                radius: 25,
                x: 0,
                y: 15
            )
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 5,
                x: 0,
                y: 2
            )
        )
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 8) // Reduced padding
        .background(
            // Background that extends to bottom edge
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TabBarButton: View {
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
            // Enhanced haptic feedback for add button
            let impactFeedback = UIImpactFeedbackGenerator(style: isAddButton ? .heavy : .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            VStack(spacing: 4) {
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
                            .frame(width: isSelected ? 48 : 44, height: isSelected ? 48 : 44)
                            .overlay(
                                Circle()
                                    .stroke(
                                        Color.white.opacity(0.8),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(
                                color: Color.blue.opacity(0.4),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                            .shadow(
                                color: Color.purple.opacity(0.3),
                                radius: 6,
                                x: 0,
                                y: 2
                            )
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    } else {
                        // Background circle for selected state (regular tabs)
                        if isSelected {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.3),
                                            Color.purple.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                )
                                .scaleEffect(isSelected ? 1.0 : 0.8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                        }
                    }
                    
                    // Icon
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: isAddButton ? 22 : 20, weight: isAddButton ? .bold : (isSelected ? .semibold : .medium)))
                        .foregroundStyle(
                            isAddButton ?
                            LinearGradient(
                                colors: [Color.white],
                                startPoint: .center,
                                endPoint: .center
                            ) :
                            (isSelected ? 
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.primary.opacity(0.6)],
                                startPoint: .center,
                                endPoint: .center
                            ))
                        )
                        .scaleEffect(isSelected ? (isAddButton ? 1.05 : 1.1) : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                        .shadow(
                            color: isAddButton ? Color.white.opacity(0.3) : Color.clear,
                            radius: isAddButton ? 4 : 0
                        )
                }
                
                // Label
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
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
                            colors: [Color.primary.opacity(0.6)],
                            startPoint: .center,
                            endPoint: .center
                        ))
                    )
                    .scaleEffect(isSelected ? 1.05 : (isAddButton ? 1.02 : 1.0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct TabItem {
    let title: String
    let icon: String
    let selectedIcon: String
    
    init(title: String, icon: String, selectedIcon: String? = nil) {
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon ?? icon
    }
}

// MARK: - Preview
struct LiquidGlassTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            LiquidGlassTabBar(
                selectedTab: .constant(0),
                tabs: [
                    TabItem(title: "首页", icon: "house", selectedIcon: "house.fill"),
                    TabItem(title: "项目", icon: "folder", selectedIcon: "folder.fill"),
                    TabItem(title: "任务", icon: "checkmark.circle", selectedIcon: "checkmark.circle.fill"),
                    TabItem(title: "团队", icon: "person.2", selectedIcon: "person.2.fill"),
                    TabItem(title: "设置", icon: "gearshape", selectedIcon: "gearshape.fill")
                ]
            )
        }
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .ignoresSafeArea()
    }
}