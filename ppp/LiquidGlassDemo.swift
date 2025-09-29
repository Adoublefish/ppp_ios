import SwiftUI

struct LiquidGlassDemo: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.2),
                    Color.pink.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating elements for depth
            VStack {
                Spacer()
                
                // Demo content
                VStack(spacing: 20) {
                    Text("液态玻璃导航栏")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("悬浮在底部中间的毛玻璃效果")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Sample cards
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(0..<4) { index in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .frame(height: 100)
                                .overlay(
                                    VStack {
                                        Image(systemName: ["star.fill", "heart.fill", "bolt.fill", "leaf.fill"][index])
                                            .font(.title)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        Text("卡片 \(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                Spacer() // Extra space for tab bar
            }
            
            // Liquid Glass Tab Bar
            VStack {
                Spacer()
                LiquidGlassTabBar(
                    selectedTab: $selectedTab,
                    tabs: [
                        TabItem(title: "首页", icon: "house", selectedIcon: "house.fill"),
                        TabItem(title: "项目", icon: "folder", selectedIcon: "folder.fill"),
                        TabItem(title: "任务", icon: "checkmark.circle", selectedIcon: "checkmark.circle.fill"),
                        TabItem(title: "团队", icon: "person.2", selectedIcon: "person.2.fill"),
                        TabItem(title: "设置", icon: "gearshape", selectedIcon: "gearshape.fill")
                    ]
                )
            }
        }
    }
}

// MARK: - Preview
struct LiquidGlassDemo_Previews: PreviewProvider {
    static var previews: some View {
        LiquidGlassDemo()
    }
}