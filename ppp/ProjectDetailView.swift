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
    
    // Mock data for project tasks
    @State private var projectTasks: [ProjectTask] = []
    
    private let filterOptions = ["全部任务", "已完成", "进行中", "逾期", "高优先级"]
    
    private var filteredTasks: [ProjectTask] {
        switch selectedFilter {
        case "已完成":
            return projectTasks.filter { $0.status == .completed }
        case "进行中":
            return projectTasks.filter { $0.status == .inProgress }
        case "逾期":
            return projectTasks.filter { $0.isOverdue }
        case "高优先级":
            return projectTasks.filter { $0.priority == .high || $0.priority == .urgent }
        default:
            return projectTasks
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
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .onAppear {
            loadProjectTasks()
        }
        .sheet(isPresented: $showingAIAssistant) {
            AIAssistantView(project: project)
        }
    }
    
    // MARK: - Compact Header View (10% of screen)
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
        .padding(.top, 60)
        .padding(.bottom, 16)
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
                    projectColor: project.color
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
    
    private func loadProjectTasks() {
        // Mock data based on the project
        let calendar = Calendar.current
        let today = Date()
        
        projectTasks = [
            ProjectTask(
                id: UUID(),
                title: "品牌定位研究",
                description: "市场调研和品牌定位分析",
                assignee: TeamMember(name: "张明", avatar: "person.circle.fill"),
                status: .completed,
                priority: .medium,
                timeLogged: 28800, // 8 hours
                dueDate: calendar.date(byAdding: .day, value: -10, to: today)!,
                completedDate: calendar.date(byAdding: .day, value: -12, to: today)!
            ),
            ProjectTask(
                id: UUID(),
                title: "视觉风格指南",
                description: "制定品牌视觉识别系统",
                assignee: TeamMember(name: "李华", avatar: "person.circle.fill"),
                status: .inProgress,
                priority: .high,
                timeLogged: 43200, // 12 hours
                dueDate: calendar.date(byAdding: .day, value: 2, to: today)!,
                completedDate: calendar.date(byAdding: .day, value: -12, to: today)!
            ),
            ProjectTask(
                id: UUID(),
                title: "标志设计",
                description: "创建新的品牌标志设计",
                assignee: TeamMember(name: "王芳", avatar: "person.circle.fill"),
                status: .completed,
                priority: .high,
                timeLogged: 57600, // 16 hours
                dueDate: calendar.date(byAdding: .day, value: -5, to: today)!,
                completedDate: calendar.date(byAdding: .day, value: -7, to: today)!
            )
        ]
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
    let task: ProjectTask
    let isLast: Bool
    let projectColor: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(task.status == .completed ? Color.green : 
                          task.status == .inProgress ? Color.blue : Color.gray)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 2, height: 60)
                }
            }
            
            // Task content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(task.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(task.status == .completed ? "已完成" : "进行中")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(task.status == .completed ? Color.green : Color.orange)
                        .cornerRadius(12)
                }
                
                // Assignee info
                HStack(spacing: 8) {
                    Image(systemName: task.assignee.avatar ?? "person.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color(hex: projectColor))
                    
                    Text(task.assignee.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Time and date info
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(task.formattedTimeLogged)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(formatTaskDate(task))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .padding(.bottom, isLast ? 0 : 16)
    }
    
    private func formatTaskDate(_ task: ProjectTask) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let completedDate = task.completedDate {
            return formatter.string(from: completedDate)
        } else {
            return formatter.string(from: task.dueDate)
        }
    }
}

// MARK: - Project Task Model
struct ProjectTask: Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let assignee: TeamMember
    let status: TaskStatus
    let priority: TaskPriority
    let timeLogged: TimeInterval
    let dueDate: Date
    let completedDate: Date?
    
    enum TaskStatus {
        case pending, inProgress, completed, overdue
    }
    
    var formattedTimeLogged: String {
        let hours = Int(timeLogged) / 3600
        return "\(hours)小时"
    }
    
    var isOverdue: Bool {
        return Date() > dueDate && status != .completed
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
