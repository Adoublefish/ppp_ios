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
    
    private let filters = ["全部", "进行中", "已完成", "规划中"]
    
    private var statistics: ProjectStatistics {
        ProjectStatistics(
            totalProjects: dataManager.allProjects.count,
            activeProjects: dataManager.allProjects.filter { $0.status == .active }.count,
            completedProjects: dataManager.allProjects.filter { $0.status == .completed }.count
        )
    }
    
    private var personalProjects: [Project] {
        return dataManager.getPersonalProjects()
    }
    
    private var teamProjects: [Project] {
        return dataManager.allProjects.filter { project in
            dataManager.teams.contains { $0.id == project.ownerId }
        }
    }
    
    private var filteredPersonalProjects: [Project] {
        return filterProjects(personalProjects)
    }
    
    private var filteredTeamProjects: [Project] {
        return filterProjects(teamProjects)
    }
    
    private func filterProjects(_ projects: [Project]) -> [Project] {
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
            compactHeaderView
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
            
            filterBarView
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    if !filteredPersonalProjects.isEmpty {
                        sectionHeader(title: "个人项目", count: filteredPersonalProjects.count, accent: .blue)
                            .padding(.horizontal, 20)
                        
                        ForEach(filteredPersonalProjects) { project in
                            ProjectOverviewCard(project: project, categoryLabel: "个人")
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    if !filteredTeamProjects.isEmpty {
                        sectionHeader(title: "团队项目", count: filteredTeamProjects.count, accent: .green)
                            .padding(.horizontal, 20)
                        
                        ForEach(filteredTeamProjects) { project in
                            ProjectOverviewCard(project: project, categoryLabel: getTeamForProject(project).name)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    if filteredPersonalProjects.isEmpty && filteredTeamProjects.isEmpty {
                        emptyStateView
                            .padding(.top, 80)
                    }
                }
                .padding(.vertical, 20)
                .padding(.bottom, 100)
            }
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
    }
    
    private func getTeamForProject(_ project: Project) -> Team {
        return dataManager.teams.first { $0.id == project.ownerId } ?? 
               Team(name: "Unknown Team", description: "Team not found")
    }
    
    // MARK: - Compact Header View - Neumorphic Style
    private var compactHeaderView: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("项目概览")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("管理个人与团队项目进度")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                // Search action placeholder
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Statistics Row View - Neumorphic Style
    private var statisticsRowView: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("\(statistics.totalProjects)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.neuAccent)
                
                Text("总项目")
                    .font(.caption)
                    .foregroundColor(.neuTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .neumorphicInset(cornerRadius: 16)
            
            VStack(spacing: 4) {
                Text("\(statistics.activeProjects)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                
                Text("进行中")
                    .font(.caption)
                    .foregroundColor(.neuTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .neumorphicInset(cornerRadius: 16)
            
            VStack(spacing: 4) {
                Text("\(statistics.completedProjects)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                Text("已完成")
                    .font(.caption)
                    .foregroundColor(.neuTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .neumorphicInset(cornerRadius: 16)
        }
    }
    
    // MARK: - Filter Bar View - Neumorphic Style
    private var filterBarView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { filter in
                    let isSelected = selectedFilter == filter
                    Text(filter)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.blue : Color(.systemGray6))
                        )
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                        )
                        .onTapGesture {
                            selectedFilter = filter
                        }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func sectionHeader(title: String, count: Int, accent: Color) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(count) 项目")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(accent.opacity(0.12))
                )
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.secondary)
            
            Text("暂无匹配的项目")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("试试修改筛选条件或搜索内容")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 32)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Project Overview Card
struct ProjectOverviewCard: View {
    let project: Project
    let categoryLabel: String
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(hex: project.color))
                    .frame(width: 6)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(project.name)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(project.completedTasks)/\(project.totalTasks) 任务")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person.2")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(categoryLabel)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12, weight: .medium))
                            Text("Last Update: \(formatDate(project.updatedAt))")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showingDetail) {
            ProjectDetailView(project: project)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
                
                // Time Statistics
                let timeStats = TaskDataManager.shared.getProjectTimeStats(projectId: project.id)
                if timeStats.totalActualHours > 0 || timeStats.totalEstimatedHours > 0 {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("预估: \(timeStats.formattedEstimatedTime)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("实际: \(timeStats.formattedActualTime)")
                                .font(.caption2)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("效率")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text(String(format: "%.0f%%", timeStats.efficiency * 100))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(timeStats.efficiency <= 1.0 ? .green : .orange)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(8)
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

// MARK: - Personal Project Card View
struct PersonalProjectCardView: View {
    let project: Project
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 12) {
                // Left: Color indicator
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: project.color))
                    .frame(width: 4)
                
                // Middle: Project info
                VStack(alignment: .leading, spacing: 6) {
                    // Project name and type
                    HStack {
                        Text(project.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.neuTextPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("个人")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.neuAccent.opacity(0.15))
                            .foregroundColor(.neuAccent)
                            .cornerRadius(6)
                    }
                    
                    // Progress bar
                    HStack(spacing: 8) {
                        NeumorphicProgressView(
                            progress: project.progressPercentage,
                            color: Color(hex: project.color),
                            height: 6
                        )
                        
                        Text("\(Int(project.progressPercentage * 100))%")
                            .font(.caption2)
                            .foregroundColor(.neuTextSecondary)
                            .frame(width: 35, alignment: .trailing)
                    }
                    
                    // Due date and tasks
                    HStack(spacing: 8) {
                        if let endDate = project.endDate {
                            HStack(spacing: 3) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                Text(formatDate(endDate))
                                    .font(.caption2)
                            }
                            .foregroundColor(.neuTextSecondary)
                        }
                        
                        Spacer()
                        
                        Text("\(project.completedTasks)/\(project.totalTasks) 任务")
                            .font(.caption2)
                            .foregroundColor(.neuTextSecondary)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .neumorphicCard(cornerRadius: 16, padding: 12)
        .fullScreenCover(isPresented: $showingDetail) {
            ProjectDetailView(project: project)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }
    
    private func getStatusText() -> String {
        if project.isOverdue {
            return "逾期"
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

// MARK: - Team Project Overview Card View
struct TeamProjectOverviewCardView: View {
    let project: Project
    let team: Team
    
    @State private var showingDetail = false
    @State private var showingCreateTask = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 12) {
                // Left: Color indicator
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: project.color))
                    .frame(width: 4)
                
                // Middle: Project info
                VStack(alignment: .leading, spacing: 6) {
                    // Project name and team
                    HStack {
                        Text(project.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.neuTextPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(team.name)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.green)
                            .cornerRadius(6)
                    }
                
                    // Progress bar
                    HStack(spacing: 8) {
                        NeumorphicProgressView(
                            progress: project.progressPercentage,
                            color: Color(hex: project.color),
                            height: 6
                        )
                        
                        Text("\(Int(project.progressPercentage * 100))%")
                            .font(.caption2)
                            .foregroundColor(.neuTextSecondary)
                            .frame(width: 35, alignment: .trailing)
                    }
                
                    // Team members and tasks
                    HStack(spacing: 8) {
                        HStack(spacing: -6) {
                            ForEach(Array(team.members.prefix(3).enumerated()), id: \.offset) { index, member in
                                Circle()
                                    .fill(Color(hex: project.color))
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Text(String(member.name.prefix(1)).uppercased())
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            if team.members.count > 3 {
                                Circle()
                                    .fill(Color.neuAccent.opacity(0.3))
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Text("+\(team.members.count - 3)")
                                            .font(.system(size: 8, weight: .semibold))
                                            .foregroundColor(.neuTextPrimary)
                                    )
                            }
                        }
                        
                        Spacer()
                        
                        Text("\(project.completedTasks)/\(project.totalTasks) 任务")
                            .font(.caption2)
                            .foregroundColor(.neuTextSecondary)
                    }
                }
                
            }
        }
        .foregroundColor(.primary)
        .neumorphicCard(cornerRadius: 16, padding: 12)
        .sheet(isPresented: $showingCreateTask) {
            TaskInputView(team: team, project: project)
        }
        .fullScreenCover(isPresented: $showingDetail) {
            ProjectDetailView(project: project)
        }
    }
}

// MARK: - Create Team Task from Overview
struct CreateTeamTaskOverviewView: View {
    let project: Project
    let team: Team
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var selectedPriority = TaskPriority.medium
    @State private var selectedCategory = TaskCategory.development
    @State private var selectedAssignee: UUID?
    @State private var dueDate: Date?
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var hasDueDate = false
    @State private var hasTimeRange = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Project Info Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Creating task for")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(team.icon)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("Team: \(team.name)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: project.color).opacity(0.1))
                        )
                    }
                    
                    // Task Basic Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Task Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter task title", text: $taskTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter task description", text: $taskDescription, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                    }
                    
                    // Priority Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Priority")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 12) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Button(action: {
                                    selectedPriority = priority
                                }) {
                                    Text(priority.rawValue.capitalized)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedPriority == priority ? priorityColor(priority) : Color(.systemGray5))
                                        .foregroundColor(selectedPriority == priority ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(TaskCategory.defaultCategories, id: \.self) { category in
                                Text(category.displayName).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Assignee Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Assign to Team Member")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Unassigned option
                                Button(action: {
                                    selectedAssignee = nil
                                }) {
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(selectedAssignee == nil ? Color.blue : Color(.systemGray5))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "person.slash")
                                                    .font(.caption)
                                                    .foregroundColor(selectedAssignee == nil ? .white : .secondary)
                                            )
                                        
                                        Text("Unassigned")
                                            .font(.caption2)
                                            .foregroundColor(selectedAssignee == nil ? .blue : .secondary)
                                    }
                                }
                                
                                // Team members
                                ForEach(Array(team.members.enumerated()), id: \.offset) { index, member in
                                    Button(action: {
                                        selectedAssignee = member.id
                                    }) {
                                        VStack(spacing: 4) {
                                            Circle()
                                                .fill(selectedAssignee == member.id ? Color.blue : Color(.systemGray5))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Text(String(member.name.prefix(1)).uppercased())
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(selectedAssignee == member.id ? .white : .secondary)
                                                )
                                            
                                            Text(member.name)
                                                .font(.caption2)
                                                .foregroundColor(selectedAssignee == member.id ? .blue : .secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                    
                    // Due Date
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Due Date")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Toggle("", isOn: $hasDueDate)
                        }
                        
                        if hasDueDate {
                            DatePicker("Due Date", selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                        }
                    }
                    
                    // Time Range
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Time Range")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Toggle("", isOn: $hasTimeRange)
                        }
                        
                        if hasTimeRange {
                            VStack(spacing: 8) {
                                DatePicker("Start Time", selection: Binding(
                                    get: { startTime ?? Date() },
                                    set: { startTime = $0 }
                                ), displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                                
                                DatePicker("End Time", selection: Binding(
                                    get: { endTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: startTime ?? Date()) ?? Date() },
                                    set: { endTime = $0 }
                                ), displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Create Team Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createTeamTask()
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .urgent: return .purple
        }
    }
    
    private func createTeamTask() {
        let newTask = Task(
            title: taskTitle,
            description: taskDescription,
            startTime: hasTimeRange ? startTime : nil,
            endTime: hasTimeRange ? endTime : nil,
            dueDate: hasDueDate ? dueDate : nil,
            priority: selectedPriority,
            category: selectedCategory,
            projectId: project.id,
            assigneeId: selectedAssignee
        )
        
        dataManager.addTask(newTask)
        
        // Update project task counts
        let updatedProject = Project(
            id: project.id,
            name: project.name,
            description: project.description,
            startDate: project.startDate,
            endDate: project.endDate,
            status: project.status,
            ownerId: project.ownerId,
            createdAt: project.createdAt,
            updatedAt: Date(),
            color: project.color,
            totalTasks: project.totalTasks + 1,
            activeTasks: project.activeTasks + 1,
            completedTasks: project.completedTasks,
            teamMembers: project.teamMembers,
            timeLogged: project.timeLogged
        )
        
        dataManager.updateProject(updatedProject)
        dismiss()
    }
}

#Preview {
    ProjectOverviewView()
} 
