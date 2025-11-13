import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    private let tabs = [
        TabItem(title: "首页", icon: "house", selectedIcon: "house.fill"),
        TabItem(title: "项目", icon: "folder", selectedIcon: "folder.fill"),
        TabItem(title: "添加", icon: "plus", selectedIcon: "plus.circle.fill"),
        TabItem(title: "团队", icon: "person.2", selectedIcon: "person.2.fill"),
        TabItem(title: "设置", icon: "gearshape", selectedIcon: "gearshape.fill")
    ]
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case 0:
                            DashboardView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case 1:
                            ProjectOverviewView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case 2:
                            TaskInputView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case 3:
                            TeamCollaborationView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case 4:
                            SettingsView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        default:
                            DashboardView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        tabs: tabs
                    )
                    .padding(.top, 4)
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
