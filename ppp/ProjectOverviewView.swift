//
//  ProjectOverviewView.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import SwiftUI

struct ProjectOverviewView: View {
    @State private var selectedFilter = "全部"
    @State private var searchText = ""
    
    // Mock data for projects
    @State private var projects: [Project] = {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            Project(
                name: "电商平台开发",
                description: "构建现代化电商平台",
                startDate: calendar.date(byAdding: .month, value: -2, to: today)!,
                endDate: calendar.date(byAdding: .day, value: 5, to: today)!,
                status: .active,
                ownerId: UUID(),
                color: "#3B82F6",
                totalTasks: 15,
                activeTasks: 8,
                completedTasks: 7,
                teamMembers: [
                    TeamMember(name: "张三", avatar: "person.circle.fill", isOnline: true),
                    TeamMember(name: "李四", avatar: "person.circle.fill", isOnline: false),
                    TeamMember(name: "王五", avatar: "person.circle.fill", isOnline: true)
                ],
                timeLogged: 432000 // 120 hours
            ),
            Project(
                name: "营销活动设计",
                description: "双十一营销活动策划与执行",
                startDate: calendar.date(byAdding: .month, value: -1, to: today)!,
                endDate: calendar.date(byAdding: .day, value: -3, to: today)!,
                status: .active,
                ownerId: UUID(),
                color: "#F59E0B",
                totalTasks: 8,
                activeTasks: 3,
                completedTasks: 5,
                teamMembers: [
                    TeamMember(name: "小明", avatar: "person.circle.fill", isOnline: true),
                    TeamMember(name: "小红", avatar: "person.circle.fill", isOnline: true)
                ],
                timeLogged: 288000 // 80 hours
            ),
            Project(
                name: "产品发布会",
                description: "新产品发布会筹备工作",
                startDate: calendar.date(byAdding: .month, value: -3, to: today)!,
                endDate: calendar.date(byAdding: .day, value: -10, to: today)!,
                status: .completed,
                ownerId: UUID(),
                color: "#10B981",
                totalTasks: 12,
                activeTasks: 0,
                completedTasks: 12,
                teamMembers: [
                    TeamMember(name: "小刚", avatar: "person.circle.fill", isOnline: false),
                    TeamMember(name: "小芳", avatar: "person.circle.fill", isOnline: true),
                    TeamMember(name: "小强", avatar: "person.circle.fill", isOnline: false)
                ],
                timeLogged: 360000 // 100 hours
            ),
            Project(
                name: "移动应用优化",
                description: "提升APP性能和用户体验",
                startDate: calendar.date(byAdding: .weekOfYear, value: -3, to: today)!,
                endDate: calendar.date(byAdding: .weekOfYear, value: 2, to: today)!,
                status: .active,
                ownerId: UUID(),
                color: "#8B5CF6",
                totalTasks: 10,
                activeTasks: 6,
                completedTasks: 4,
                teamMembers: [
                    TeamMember(name: "小李", avatar: "person.circle.fill", isOnline: true),
                    TeamMember(name: "小张", avatar: "person.circle.fill", isOnline: true),
                    TeamMember(name: "小王", avatar: "person.circle.fill", isOnline: false),
                    TeamMember(name: "小赵", avatar: "person.circle.fill", isOnline: true)
                ],
                timeLogged: 216000 // 60 hours
            )
        ]
    }()
    
    private var statistics: ProjectStatistics {
        ProjectStatistics(
            totalProjects: projects.count,
            activeProjects: projects.filter { $0.status == .active }.count,
            completedProjects: projects.filter { $0.status == .completed }.count
        )
    }
    
    private var filteredProjects: [Project] {
        var filtered = projects
        
        // Apply status filter
        if selectedFilter != "全部" {
            switch selectedFilter {
            case "进行中":
                filtered = filtered.filter { $0.status == .active }
            case "已完成":
                filtered = filtered.filter { $0.status == .completed }
            case "规划中":
                filtered = filtered.filter { $0.status == .planning }
            default:
                break
            }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact Header (10% of screen)
            compactHeaderView
            
            // Statistics Row
            statisticsRowView
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            
            // Filter Bar
            filterBarView
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // Projects List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredProjects) { project in
                        ProjectCardView(project: project)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 100) // Space for bottom navigation
            }
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Compact Header View (10% of screen)
    private var compactHeaderView: some View {
        HStack {
            Text("项目概览")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                // Search action
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60) // Status bar
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Statistics Row View
    private var statisticsRowView: some View {
        HStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("\(statistics.totalProjects)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("总项目")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 4) {
                Text("\(statistics.activeProjects)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "F59E0B"))
                
                Text("进行中")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 4) {
                Text("\(statistics.completedProjects)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "10B981"))
                
                Text("已完成")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Filter Bar View
    private var filterBarView: some View {
        HStack {
            Text("全部")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray5))
                .cornerRadius(20)
            
            Spacer()
        }
    }
}

// MARK: - Project Card View (Same as before)
struct ProjectCardView: View {
    let project: Project
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Project Header
                HStack {
                    Text(project.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        // More options
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Team Members
                HStack(spacing: 8) {
                    ForEach(Array(project.teamMembers.prefix(3).enumerated()), id: \.offset) { index, member in
                        Image(systemName: member.avatar ?? "person.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color(hex: project.color))
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: CGFloat(-index * 8))
                    }
                    
                    if project.teamMembers.count > 3 {
                        Text("等 \(project.teamMembers.count) 人")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .offset(x: CGFloat(-(min(project.teamMembers.count, 3) - 1) * 8))
                    }
                    
                    Spacer()
                }
                
                // Due Date and Status
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let endDate = project.endDate {
                            Text("截止日期：\(formatDate(endDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    Text(getStatusText())
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(getStatusColor())
                        .cornerRadius(12)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingDetail) {
            ProjectDetailView(project: project)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func getStatusText() -> String {
        if project.isOverdue {
            return "即将到期"
        }
        return project.statusDisplayName
    }
    
    private func getStatusColor() -> Color {
        if project.isOverdue {
            return Color(hex: "EF4444") // Red for overdue
        }
        return Color(hex: project.statusColor)
    }
}

// MARK: - Color Extension
extension Color {
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

#Preview {
    ProjectOverviewView()
} 
