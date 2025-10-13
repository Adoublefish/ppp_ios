import SwiftUI

struct TabBarTestView: View {
    @State private var selectedTab = 0
    @State private var useAdvancedVersion = false
    
    private let tabs = [
        TabItem(title: "首页", icon: "house", selectedIcon: "house.fill"),
        TabItem(title: "项目", icon: "folder", selectedIcon: "folder.fill"),
        TabItem(title: "任务", icon: "checkmark.circle", selectedIcon: "checkmark.circle.fill"),
        TabItem(title: "团队", icon: "person.2", selectedIcon: "person.2.fill"),
        TabItem(title: "设置", icon: "gearshape", selectedIcon: "gearshape.fill")
    ]
    
    var body: some View {
        ZStack {
            // Neumorphic background
            Color.neuBackground
                .ignoresSafeArea()
            
            VStack {
                // Header
                VStack(spacing: 20) {
                    Text("液态玻璃导航栏测试")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("当前选中: \(tabs[selectedTab].title)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    // Toggle for version
                    Toggle("使用高级版本", isOn: $useAdvancedVersion)
                        .padding(.horizontal, 40)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Content area based on selected tab
                VStack(spacing: 20) {
                    Image(systemName: tabs[selectedTab].selectedIcon)
                        .font(.system(size: 80))
                        .foregroundColor(.neuAccent)
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selectedTab)
                    
                    Text(tabs[selectedTab].title)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("这是 \(tabs[selectedTab].title) 页面的内容")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                Spacer() // Extra space for tab bar
            }
            
            // Tab Bar
            VStack {
                Spacer()
                if useAdvancedVersion {
                    NeumorphicInsetTabBar(
                        selectedTab: $selectedTab,
                        tabs: tabs
                    )
                } else {
                    NeumorphicTabBar(
                        selectedTab: $selectedTab,
                        tabs: tabs
                    )
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: useAdvancedVersion)
    }
}

// MARK: - Preview
struct TabBarTestView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarTestView()
    }
}