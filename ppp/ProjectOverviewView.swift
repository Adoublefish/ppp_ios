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
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    private var statistics: ProjectStatistics {
        ProjectStatistics(
            totalProjects: dataManager.allProjects.count,
            activeProjects: dataManager.allProjects.filter { $0.status == .active }.count,
            completedProjects: dataManager.allProjects.filter { $0.status == .completed }.count
        )
    }
    
    private var filteredProjects: [Project] {
        var filtered = dataManager.allProjects
        
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
        
        // Sort by latest task creation time (newest first)
        return filtered.sorted { project1, project2 in
            let tasks1 = dataManager.tasksForProject(project1.id)
            let tasks2 = dataManager.tasksForProject(project2.id)
            
            // Get the latest task creation time for each project
            let latestTime1 = tasks1.map { $0.createdAt }.max() ?? Date.distantPast
            let latestTime2 = tasks2.map { $0.createdAt }.max() ?? Date.distantPast
            
            return latestTime1 > latestTime2 // 从新到老排序
        }
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
        .padding(.top, 50) // Status bar - reduced from 60
        .padding(.bottom, 12) // reduced from 16
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
                
                // Project Description (if available)
                if let description = project.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
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



#Preview {
    ProjectOverviewView()
} 
