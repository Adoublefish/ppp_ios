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
    
    private let filterOptions = ["全部任务", "已完成", "进行中", "逾期", "高优先级"]
    
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
        case "高优先级":
            return projectTasks.filter { $0.priority == .high || $0.priority == .urgent }.sorted { $0.createdAt < $1.createdAt }
        default:
            // 默认按创建时间排序（时间线按创建时间显示）
            return projectTasks.sorted { $0.createdAt < $1.createdAt }
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
                    // Progress Section
                    progressSection
                    
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
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Title
            Text(project.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            // Share Button
            Button(action: {
                // Share action
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8) // 大幅减少顶部距离
        .padding(.bottom, 8) // 减少底部距离
        .background(Color(hex: project.color))
    }
    
    // MARK: - Project Info Row
    private var projectInfoRowView: some View {
        VStack(spacing: 12) {
            // Status
            HStack {
                Text(project.statusDisplayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: project.statusColor))
                    .cornerRadius(16)
                
                Spacer()
            }
            
            // Info Grid (2x2)
            HStack(spacing: 20) {
                // Due Date
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("截止日期")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatDate(project.endDate))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                // Time Investment
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("已投入")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(project.formattedTimeLogged)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("任务进度")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("已完成 \(project.completedTasks)/\(project.totalTasks) 个任务")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress Bar
            ProgressView(value: project.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: project.color)))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
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
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Timeline Section
    private var timelineSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(filteredTasks.enumerated()), id: \.offset) { index, task in
                                    TimelineTaskView(
                        task: task,
                        isLast: index == filteredTasks.count - 1,
                        projectColor: project.color,
                        onTaskTap: { selectedTask = task }
                    )
            }
        }
    }
    
    // MARK: - AI Assistant Section
    private var aiAssistantSection: some View {
        Button(action: {
            showingAIAssistant = true
        }) {
            HStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI 项目助手")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("可查看项目总结或生成邮件")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(20)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "8B5CF6"), Color(hex: "3B82F6")]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

struct TimelineTaskView: View {
    let task: Task
    let isLast: Bool
    let projectColor: String
    let onTaskTap: () -> Void
    
    var body: some View {
        Button(action: onTaskTap) {
            HStack(alignment: .top, spacing: 16) {
                // Timeline indicator
                VStack(spacing: 0) {
                    Circle()
                        .fill(task.isCompleted ? Color.green : Color.blue)
                        .frame(width: 12, height: 12)
                    
                    if !isLast {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 2, height: 80) // 增加高度以适应新内容
                    }
                }
                
                // Task content - 增强版本：显示title、分类标签、优先级和负责人
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(task.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    // Description (if available)
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Category Tag and Priority
                    HStack(spacing: 8) {
                        // Category Tag
                        HStack(spacing: 4) {
                            Image(systemName: getCategoryIcon())
                                .font(.caption2)
                                .foregroundColor(getCategoryColor())
                            
                            Text(getCategoryDisplayName())
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(getCategoryColor().opacity(0.1))
                        .cornerRadius(8)
                        
                        // Priority Tag
                        HStack(spacing: 4) {
                            Circle()
                                .fill(priorityColor(task.priority))
                                .frame(width: 6, height: 6)
                            
                            Text(priorityDisplayName(task.priority))
                                .font(.caption2)
                                .foregroundColor(priorityColor(task.priority))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(priorityColor(task.priority).opacity(0.1))
                        .cornerRadius(8)
                        
                        Spacer()
                    }
                    
                    // Assignee and Date
                    HStack {
                        Image(systemName: "person.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let assigneeId = task.assigneeId {
                            Text("负责人: \(getAssigneeName(assigneeId))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("未分配")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 创建时间
                        Text(formatCreatedDate(task.createdAt))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, isLast ? 0 : 16)
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
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .urgent: return .purple
        }
    }
    
    /// 获取负责人姓名
    private func getAssigneeName(_ assigneeId: UUID) -> String {
        // 为演示目的，根据固定的UUID返回对应的用户名
        // 在实际应用中，应该从用户数据库或缓存中获取用户名
        let idString = assigneeId.uuidString
        
        // 匹配我们在TaskDataManager中创建的固定UUID
        if idString == "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA" {
            return "Jim"
        } else if idString == "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB" {
            return "Clare"
        } else {
            return "未知用户"
        }
    }
    
    /// 格式化创建日期
    private func formatCreatedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    /// 获取分类显示名称
    private func getCategoryDisplayName() -> String {
        let dataManager = TaskDataManager.shared
        
        if task.category == .custom, let customCategoryId = task.customCategoryId,
           let customCategory = dataManager.getCustomCategory(byId: customCategoryId) {
            return customCategory.name
        } else {
            return task.category.displayName
        }
    }
    
    /// 获取分类图标
    private func getCategoryIcon() -> String {
        let dataManager = TaskDataManager.shared
        
        if task.category == .custom, let customCategoryId = task.customCategoryId,
           let customCategory = dataManager.getCustomCategory(byId: customCategoryId) {
            return customCategory.icon
        } else {
            return getCategoryIconForDefault(task.category)
        }
    }
    
    /// 获取分类颜色
    private func getCategoryColor() -> Color {
        let dataManager = TaskDataManager.shared
        
        if task.category == .custom, let customCategoryId = task.customCategoryId,
           let customCategory = dataManager.getCustomCategory(byId: customCategoryId) {
            return Color(hex: customCategory.color)
        } else {
            return getCategoryColorForDefault(task.category)
        }
    }
    
    /// 获取默认分类图标
    private func getCategoryIconForDefault(_ category: TaskCategory) -> String {
        switch category {
        case .meeting: return "person.2"
        case .review: return "checkmark.circle"
        case .development: return "hammer"
        case .design: return "paintbrush"
        case .communication: return "message"
        case .presentation: return "presentation"
        case .milestone: return "flag"
        case .planning: return "calendar"
        case .testing: return "testtube.2"
        case .documentation: return "doc.text"
        case .custom: return "folder"
        }
    }
    
    /// 获取默认分类颜色
    private func getCategoryColorForDefault(_ category: TaskCategory) -> Color {
        switch category {
        case .meeting: return Color.blue
        case .review: return Color.green
        case .development: return Color.orange
        case .design: return Color.purple
        case .communication: return Color.cyan
        case .presentation: return Color.red
        case .milestone: return Color.yellow
        case .planning: return Color.indigo
        case .testing: return Color.pink
        case .documentation: return Color.brown
        case .custom: return Color.gray
        }
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
