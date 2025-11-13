//
//  ProjectDetailView.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter = "全部任务"
    @State private var showingAIAssistant = false
    @State private var selectedTask: Task? = nil
    @ObservedObject private var dataManager = TaskDataManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    
    private let filterOptions = ["全部任务", "已完成", "进行中", "逾期"]
    
    private var filteredTasks: [Task] {
        let projectTasks = dataManager.tasksForProject(project.id)
        
        switch selectedFilter {
        case "已完成":
            return projectTasks.filter { $0.isCompleted }.sorted { $0.createdAt < $1.createdAt }
        case "进行中":
            return projectTasks.filter { !$0.isCompleted }.sorted { $0.createdAt < $1.createdAt }
        case "逾期":
            return projectTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return !task.isCompleted && dueDate < Date()
            }.sorted { $0.createdAt < $1.createdAt }
        default:
            // 默认按创建时间排序（时间线按创建时间显示）
            return projectTasks.sorted { $0.createdAt < $1.createdAt }
        }
    }
    
    @ViewBuilder
    private func infoItem(icon: String, title: String, value: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.12))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact Header (10% of screen)
            compactHeaderView
            
            // Project Info Row
            projectInfoRowView
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Filter Tabs
                    filterTabsSection
                    
                    // Timeline Section
                    timelineSection
                    
                    // AI Assistant Section
                    aiAssistantSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(Color.neuBackground)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAIAssistant) {
            AIAssistantView(project: project)
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
    }
    
    // MARK: - Compact Header View - 优化顶部距离
    private var compactHeaderView: some View {
        HStack {
            // Back Button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Title
            Text(project.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
            
            // Share Button
            Button(action: {
                // Share action
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Project Info Row
    private var projectInfoRowView: some View {
        let statusColor = Color(hex: project.statusColor)
        let accentColor = Color(hex: project.color)
        
        return VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(project.statusDisplayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.12))
                    .cornerRadius(18)
                
                Spacer()
                
                Text("\(project.completedTasks)/\(project.totalTasks) 任务")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 20) {
                infoItem(
                    icon: "calendar",
                    title: "截止日期",
                    value: formatDate(project.endDate),
                    tint: accentColor
                )
                
                Divider()
                    .frame(height: 40)
                    .background(Color(.systemGray5))
                
                infoItem(
                    icon: "clock",
                    title: "已投入",
                    value: project.formattedTimeLogged,
                    tint: accentColor
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
    
    
    // MARK: - Filter Tabs Section
    private var filterTabsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filterOptions, id: \.self) { filter in
                    FilterTabView(
                        title: filter,
                        isSelected: selectedFilter == filter,
                        action: { selectedFilter = filter }
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Timeline Section
    private var timelineSection: some View {
        let sections = groupedTaskSections
        let accentColor = Color(hex: project.color)
        
        return VStack(alignment: .leading, spacing: 24) {
            if sections.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 42))
                        .foregroundColor(.secondary)
                    
                    Text("暂无相关任务")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("创建任务或调整筛选条件以查看时间线")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemBackground))
                )
            } else {
                ForEach(Array(sections.enumerated()), id: \.offset) { sectionIndex, section in
                    VStack(alignment: .leading, spacing: 18) {
                        Text(formatTimelineDate(section.date))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.secondaryLabel))
                        
                        ForEach(Array(section.tasks.enumerated()), id: \.element.id) { taskIndex, task in
                            TimelineTaskCardView(
                                task: task,
                                timeText: formatTimelineTime(for: task),
                                showTopConnector: !(sectionIndex == 0 && taskIndex == 0),
                                showBottomConnector: !(sectionIndex == sections.count - 1 && taskIndex == section.tasks.count - 1),
                                accentColor: accentColor,
                                onTap: { selectedTask = task }
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var groupedTaskSections: [(date: Date, tasks: [Task])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredTasks) { task in
            return calendar.startOfDay(for: timelineReferenceDate(for: task))
        }
        
        return grouped
            .map { (date, tasks) in
                (
                    date: date,
                    tasks: tasks.sorted { timelineReferenceDate(for: $0) < timelineReferenceDate(for: $1) }
                )
            }
            .sorted { $0.date < $1.date }
    }
    
    private func timelineReferenceDate(for task: Task) -> Date {
        if let start = task.startTime {
            return start
        } else if let due = task.dueDate {
            return due
        } else {
            return task.createdAt
        }
    }
    
    private func formatTimelineDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    private func formatTimelineTime(for task: Task) -> String {
        let date = timelineReferenceDate(for: task)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // MARK: - AI Assistant Section
    private var aiAssistantSection: some View {
        Button(action: {
            showingAIAssistant = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 52, height: 52)
                    Image(systemName: "lightbulb")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("AI 项目助手")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("智能分析项目进度，生成总结报告")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.27, green: 0.58, blue: 1.0),
                    Color(red: 0.10, green: 0.45, blue: 0.98)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "未设定" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    

}

// MARK: - Supporting Views

struct FilterTabView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : Color(.secondaryLabel))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(isSelected ? Color.blue : Color(.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(isSelected ? Color.blue : Color(.systemGray4).opacity(0.7), lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.blue.opacity(0.25) : Color.black.opacity(0.03), radius: isSelected ? 6 : 3, x: 0, y: isSelected ? 3 : 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TimelineTaskCardView: View {
    let task: Task
    let timeText: String
    let showTopConnector: Bool
    let showBottomConnector: Bool
    let accentColor: Color
    let onTap: () -> Void
    
    private let dataManager = TaskDataManager.shared
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Text(timeText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .trailing)
                    .padding(.top, 14)
                
                TimelineIndicatorView(
                    color: accentColor,
                    showTop: showTopConnector,
                    showBottom: showBottomConnector
                )

                
                VStack(alignment: .leading, spacing: 12) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                    
                    HStack(spacing: 10) {
                        categoryChip
                        priorityChip
                        Spacer()
                        assigneeView
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var categoryChip: some View {
        let info = categoryInfo
        return HStack(spacing: 6) {
            Image(systemName: info.icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(info.color)
            Text(info.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(info.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(info.color.opacity(0.12))
        .cornerRadius(14)
    }
    
    private var priorityChip: some View {
        let color = priorityColor(task.priority)
        return HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(priorityDisplayName(task.priority))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .cornerRadius(14)
    }
    
    @ViewBuilder
    private var assigneeView: some View {
        if let info = assigneeInfo {
            HStack(spacing: 8) {
                Circle()
                    .fill(info.color)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(info.initials)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    )
                Text(info.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
            }
        } else {
            Text("未分配")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
    
    private var categoryInfo: (name: String, icon: String, color: Color) {
        if task.category == .custom,
           let customCategoryId = task.customCategoryId,
           let customCategory = dataManager.getCustomCategory(byId: customCategoryId) {
            return (
                name: customCategory.name,
                icon: customCategory.icon,
                color: Color(hex: customCategory.color)
            )
        } else {
            return (
                name: task.category.displayName,
                icon: task.category.iconName,
                color: defaultCategoryColor(task.category)
            )
        }
    }
    
    private func priorityDisplayName(_ priority: TaskPriority) -> String {
        switch priority {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        case .urgent: return "紧急"
        }
    }
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .low: return Color(red: 0.27, green: 0.76, blue: 0.46)
        case .medium: return Color(red: 0.98, green: 0.64, blue: 0.14)
        case .high: return Color(red: 0.94, green: 0.31, blue: 0.31)
        case .urgent: return Color(red: 0.58, green: 0.34, blue: 0.95)
        }
    }
    
    private var assigneeInfo: (name: String, initials: String, color: Color)? {
        guard let assigneeId = task.assigneeId else {
            return nil
        }
        
        let idString = assigneeId.uuidString
        if idString == "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA" {
            return ("Jim", "J", Color(red: 0.29, green: 0.46, blue: 0.98))
        } else if idString == "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB" {
            return ("Clare", "C", Color(red: 0.98, green: 0.41, blue: 0.56))
        } else {
            return ("成员", "M", Color(.systemGray4))
        }
    }
    
    private func defaultCategoryColor(_ category: TaskCategory) -> Color {
        switch category {
        case .meeting: return Color(red: 0.30, green: 0.58, blue: 1.0)
        case .review: return Color(red: 0.27, green: 0.76, blue: 0.46)
        case .development: return Color(red: 1.0, green: 0.58, blue: 0.18)
        case .design: return Color(red: 0.83, green: 0.52, blue: 1.0)
        case .communication: return Color(red: 0.36, green: 0.74, blue: 0.99)
        case .presentation: return Color(red: 0.99, green: 0.46, blue: 0.46)
        case .milestone: return Color(red: 1.0, green: 0.78, blue: 0.26)
        case .planning: return Color(red: 0.40, green: 0.60, blue: 1.0)
        case .testing: return Color(red: 0.98, green: 0.63, blue: 0.15)
        case .documentation: return Color(red: 0.60, green: 0.62, blue: 0.68)
        case .custom: return Color(.systemGray)
        }
    }
}

struct TimelineIndicatorView: View {
    let color: Color
    let showTop: Bool
    let showBottom: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if showTop {
                Rectangle()
                    .fill(color.opacity(0.3))
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
            
            Circle()
                .strokeBorder(color, lineWidth: 3)
                .background(Circle().fill(Color(.systemBackground)))
                .frame(width: 14, height: 14)
                .padding(.vertical, 6)
            
            if showBottom {
                Rectangle()
                    .fill(color.opacity(0.45))
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 16)
    }
}



// MARK: - AI Assistant View
struct AIAssistantView: View {
    let project: Project
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("AI 项目助手")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("针对项目: \(project.name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Placeholder for AI features
                VStack(spacing: 16) {
                    AIFeatureButton(
                        icon: "doc.text",
                        title: "生成项目总结",
                        description: "自动生成项目进度报告"
                    )
                    
                    AIFeatureButton(
                        icon: "envelope",
                        title: "生成状态邮件",
                        description: "为团队或客户生成项目更新邮件"
                    )
                    
                    AIFeatureButton(
                        icon: "exclamationmark.triangle",
                        title: "识别项目风险",
                        description: "分析潜在问题和建议解决方案"
                    )
                }
                
                Spacer()
            }
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AIFeatureButton: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        Button(action: {
            // AI feature action
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ProjectDetailView(project: Project(
        name: "智能办公系统开发",
        description: "公司内部办公系统升级",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
        status: .active,
        ownerId: UUID(),
        color: "#3B82F6",
        totalTasks: 3,
        activeTasks: 1,
        completedTasks: 2,
        timeLogged: 460800 // 128 hours
    ))
} 
