//
//  AITaskBreakdownView.swift
//  ppp
//
//  Created by Kiro on 8/5/25.
//

import SwiftUI
import Foundation

struct AITaskBreakdownView: View {
    @Environment(\.dismiss) private var dismiss
    let projectTitle: String
    let projectDescription: String
    let extractedText: String
    let projectTag: String
    let dataManager: TaskDataManager
    
    @State private var isProcessing = false
    @State private var generatedTasks: [GeneratedTask] = []
    @State private var selectedTasks: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                if isProcessing {
                    // Processing View
                    processingView
                } else if generatedTasks.isEmpty {
                    // Initial View
                    initialView
                } else {
                    // Results View
                    resultsView
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            startAIBreakdown()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("取消") {
                dismiss()
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            Text("AI任务拆分")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            if !generatedTasks.isEmpty {
                Button("创建选中") {
                    createSelectedTasks()
                }
                .foregroundColor(.blue)
                .disabled(selectedTasks.isEmpty)
            } else {
                Button("") {}
                    .disabled(true)
                    .opacity(0)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8) // 大幅减少顶部距离
        .padding(.bottom, 8) // 减少底部距离
        .background(Color(.systemBackground))
    }
    
    private var processingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // AI Animation
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                    .scaleEffect(isProcessing ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isProcessing)
                
                Text("AI正在分析任务...")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("根据您的描述智能拆分子任务")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var initialView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 48))
                    .foregroundColor(.purple)
                
                Text("准备开始AI拆分")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("点击开始按钮，AI将为您智能拆分任务")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                startAIBreakdown()
            }) {
                Text("开始拆分")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 0) {
            // Summary
            summaryView
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            
            // Tasks List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(generatedTasks) { task in
                        GeneratedTaskRowView(
                            task: task,
                            isSelected: selectedTasks.contains(task.id),
                            onToggle: {
                                if selectedTasks.contains(task.id) {
                                    selectedTasks.remove(task.id)
                                } else {
                                    selectedTasks.insert(task.id)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var summaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("拆分结果")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(selectedTasks.count == generatedTasks.count ? "取消全选" : "全选") {
                    if selectedTasks.count == generatedTasks.count {
                        selectedTasks.removeAll()
                    } else {
                        selectedTasks = Set(generatedTasks.map { $0.id })
                    }
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            Text("AI为您生成了 \(generatedTasks.count) 个子任务，请选择需要创建的任务")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func startAIBreakdown() {
        isProcessing = true
        
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            generateMockTasks()
            isProcessing = false
            selectedTasks = Set(generatedTasks.map { $0.id })
        }
    }
    
    private func generateMockTasks() {
        let calendar = Calendar.current
        let today = Date()
        
        generatedTasks = [
            GeneratedTask(
                title: "需求分析和规划",
                description: "分析项目需求，制定详细的开发计划和时间表",
                estimatedDuration: "2天",
                priority: .high,
                category: .planning,
                suggestedDueDate: calendar.date(byAdding: .day, value: 2, to: today)
            ),
            GeneratedTask(
                title: "UI/UX设计",
                description: "设计用户界面和用户体验流程，创建原型图",
                estimatedDuration: "3天",
                priority: .medium,
                category: .design,
                suggestedDueDate: calendar.date(byAdding: .day, value: 5, to: today)
            ),
            GeneratedTask(
                title: "前端开发",
                description: "实现用户界面，包括响应式设计和交互功能",
                estimatedDuration: "5天",
                priority: .high,
                category: .development,
                suggestedDueDate: calendar.date(byAdding: .day, value: 10, to: today)
            ),
            GeneratedTask(
                title: "后端API开发",
                description: "开发后端接口，实现数据处理和业务逻辑",
                estimatedDuration: "4天",
                priority: .high,
                category: .development,
                suggestedDueDate: calendar.date(byAdding: .day, value: 14, to: today)
            ),
            GeneratedTask(
                title: "数据库设计",
                description: "设计数据库结构，优化查询性能",
                estimatedDuration: "2天",
                priority: .medium,
                category: .development,
                suggestedDueDate: calendar.date(byAdding: .day, value: 7, to: today)
            ),
            GeneratedTask(
                title: "功能测试",
                description: "进行全面的功能测试，确保系统稳定性",
                estimatedDuration: "3天",
                priority: .medium,
                category: .testing,
                suggestedDueDate: calendar.date(byAdding: .day, value: 17, to: today)
            ),
            GeneratedTask(
                title: "文档编写",
                description: "编写技术文档和用户手册",
                estimatedDuration: "2天",
                priority: .low,
                category: .documentation,
                suggestedDueDate: calendar.date(byAdding: .day, value: 19, to: today)
            ),
            GeneratedTask(
                title: "项目部署",
                description: "部署到生产环境，配置服务器和域名",
                estimatedDuration: "1天",
                priority: .high,
                category: .development,
                suggestedDueDate: calendar.date(byAdding: .day, value: 20, to: today)
            )
        ]
    }
    
    private func createSelectedTasks() {
        let selectedTasksToCreate = generatedTasks.filter { selectedTasks.contains($0.id) }
        
        // Find or create project
        var selectedProjectId: UUID? = nil
        if !projectTag.isEmpty {
            if let existingProject = dataManager.getProject(byName: projectTag) {
                selectedProjectId = existingProject.id
            } else {
                // Create new project
                let newProject = Project(
                    name: projectTag,
                    description: projectDescription.isEmpty ? nil : projectDescription,
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                    status: .active,
                    ownerId: UUID(),
                    color: ["#3B82F6", "#F59E0B", "#10B981", "#8B5CF6", "#EF4444"].randomElement()!
                )
                dataManager.addProject(newProject)
                selectedProjectId = newProject.id
            }
        }
        
        // Create tasks
        for generatedTask in selectedTasksToCreate {
            let newTask = Task(
                title: generatedTask.title,
                description: generatedTask.description,
                dueDate: generatedTask.suggestedDueDate,
                priority: generatedTask.priority,
                category: generatedTask.category,
                projectId: selectedProjectId
            )
            dataManager.addTask(newTask)
        }
        
        dismiss()
    }
}

struct GeneratedTask: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let estimatedDuration: String
    let priority: TaskPriority
    let category: TaskCategory
    let suggestedDueDate: Date?
}

struct GeneratedTaskRowView: View {
    let task: GeneratedTask
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Selection checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .secondary)
                
                // Task content
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 12) {
                        // Category
                        HStack(spacing: 4) {
                            Image(systemName: categoryIcon(for: task.category))
                                .font(.caption2)
                                .foregroundColor(categoryColor(for: task.category))
                            
                            Text(task.category.displayName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(categoryColor(for: task.category).opacity(0.1))
                        .cornerRadius(4)
                        
                        // Duration
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text(task.estimatedDuration)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Priority
                        Text(priorityDisplayName(task.priority))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(priorityColor(task.priority))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.05) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryIcon(for category: TaskCategory) -> String {
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
    
    private func categoryColor(for category: TaskCategory) -> Color {
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
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

#Preview {
    AITaskBreakdownView(
        projectTitle: "测试项目",
        projectDescription: "这是一个测试项目的描述",
        extractedText: "测试提取的文本",
        projectTag: "测试",
        dataManager: TaskDataManager.shared
    )
}