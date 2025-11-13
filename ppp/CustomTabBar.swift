import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    private let centerButtonIndex = 2
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(alignment: .center, spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, item in
                    if index == centerButtonIndex {
                        Spacer(minLength: 0)
                            .frame(width: 70)
                    } else {
                        standardTabButton(for: item, at: index)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(
                Capsule()
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -2)
                    .ignoresSafeArea(edges: .bottom)
            )
            
            centerButton
        }
    }
    
    private var centerButton: some View {
        Button {
            select(centerButtonIndex)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 68, height: 68)
                    .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 8)
                
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(y: -16)
        }
        .buttonStyle(.plain)
    }
    
    private func standardTabButton(for item: TabItem, at index: Int) -> some View {
        let isSelected = selectedTab == index
        let isHome = index == 0
        let activeColor: Color = isHome ? .blue : Color(.systemGray)
        let inactiveColor = Color(.systemGray3)
        
        return Button {
            select(index)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? item.selectedIcon : item.icon)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(isSelected ? activeColor : inactiveColor)
                Text(item.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? activeColor : inactiveColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private func select(_ index: Int) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
            selectedTab = index
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
