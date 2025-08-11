//
//  TaskDetailView.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import SwiftUI

struct TaskDetailView: View {
    let task: Task
    @ObservedObject private var dataManager = TaskDataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""
    @State private var editedStartTime: Date?
    @State private var editedEndTime: Date?
    @State private var editedDueDate: Date = Date()
    @State private var editedPriority: TaskPriority = .medium
    @State private var editedCategory: TaskCategory = .development
    @State private var selectedCustomCategoryId: UUID?
    @State private var selectedProjectId: UUID?
    @State private var selectedAssigneeId: UUID?
    @State private var isCompleted: Bool = false
    
    @State private var isEditing = false
    @State private var showingDatePicker = false
    @State private var showingStartTimePicker = false
    @State private var showingEndTimePicker = false
    @State private var showingProjectPicker = false
    @State private var showingAssigneePicker = false
    @State private var showingCategoryPicker = false
    
    // Computed properties
    private var currentTask: Task {
        dataManager.allTasks.first { $0.id == task.id } ?? task
    }
    
    private var associatedProject: Project? {
        guard let projectId = currentTask.projectId else { return nil }
        return dataManager.getProject(byId: projectId)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with completion toggle
                    headerSection
                    
                    // Task Details
                    taskDetailsSection
                    
                    // Project Association
                    projectSection
                    
                    // Metadata
                    metadataSection
                    
                    // Action Buttons
                    if isEditing {
                        actionButtonsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("任务详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        if isEditing {
                            cancelEditing()
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "保存" : "编辑") {
                        if isEditing {
                            saveChanges()
                        } else {
                            startEditing()
                        }
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .onAppear {
            initializeEditingState()
        }
        .sheet(isPresented: $showingDatePicker) {
            datePickerSheet
        }
        .sheet(isPresented: $showingStartTimePicker) {
            startTimePickerSheet
        }
        .sheet(isPresented: $showingEndTimePicker) {
            endTimePickerSheet
        }
        .sheet(isPresented: $showingProjectPicker) {
            projectPickerSheet
        }
        .sheet(isPresented: $showingAssigneePicker) {
            assigneePickerSheet
        }
        .sheet(isPresented: $showingCategoryPicker) {
            categoryPickerSheet
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Completion Status
            HStack {
                Button(action: {
                    toggleCompletion()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: currentTask.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(currentTask.isCompleted ? .green : .secondary)
                        
                        Text(currentTask.isCompleted ? "已完成" : "未完成")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(currentTask.isCompleted ? .green : .primary)
                    }
                }
                
                Spacer()
                
                // Priority Badge
                priorityBadge(currentTask.priority)
            }
            
            // Completion Time
            if let completedAt = currentTask.completedAt {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    Text("完成于 \(formatCompletionTime(completedAt))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Task Details Section
    private var taskDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("任务详情")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("标题")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                if isEditing {
                    TextField("输入任务标题", text: $editedTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                } else {
                    Text(currentTask.title)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("描述")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                if isEditing {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                            .frame(minHeight: 100)
                        
                        TextEditor(text: $editedDescription)
                            .padding(12)
                            .background(Color.clear)
                            .font(.body)
                        
                        if editedDescription.isEmpty {
                            Text("输入任务描述...")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 20)
                        }
                    }
                } else {
                    Text(currentTask.description.isEmpty ? "暂无描述" : currentTask.description)
                        .font(.body)
                        .foregroundColor(currentTask.description.isEmpty ? .secondary : .primary)
                }
            }
            
            // Due Date
            VStack(alignment: .leading, spacing: 8) {
                Text("截止时间")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                if isEditing {
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        HStack {
                            Text(formatDueDate(editedDueDate))
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "calendar")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                } else {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.subheadline)
                            .foregroundColor(currentTask.dueDate.map(getDueDateColor) ?? .secondary)
                        
                        Text(currentTask.dueDate.map(formatDueDate) ?? "无截止时间")
                            .font(.body)
                            .foregroundColor(currentTask.dueDate.map(getDueDateColor) ?? .secondary)
                        
                        Spacer()
                        
                        if let dueDate = currentTask.dueDate, isTaskOverdue(dueDate) && !currentTask.isCompleted {
                            Text("已逾期")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // 会议时间编辑（仅在编辑模式下显示）
            if isEditing {
                VStack(alignment: .leading, spacing: 16) {
                    Text("会议时间设置")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    // 开始时间
                    VStack(alignment: .leading, spacing: 8) {
                        Text("开始时间")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingStartTimePicker = true
                        }) {
                            HStack {
                                Text(editedStartTime.map(formatDateTime) ?? "未设置")
                                    .font(.body)
                                    .foregroundColor(editedStartTime != nil ? .primary : .secondary)
                                
                                Spacer()
                                
                                if editedStartTime != nil {
                                    Button(action: {
                                        editedStartTime = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                Image(systemName: "calendar")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    // 结束时间
                    VStack(alignment: .leading, spacing: 8) {
                        Text("结束时间")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingEndTimePicker = true
                        }) {
                            HStack {
                                Text(editedEndTime.map(formatDateTime) ?? "未设置")
                                    .font(.body)
                                    .foregroundColor(editedEndTime != nil ? .primary : .secondary)
                                
                                Spacer()
                                
                                if editedEndTime != nil {
                                    Button(action: {
                                        editedEndTime = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                Image(systemName: "calendar")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            // 负责人编辑
            VStack(alignment: .leading, spacing: 8) {
                Text("负责人")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                if isEditing {
                    Button(action: {
                        showingAssigneePicker = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.circle")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let assigneeId = selectedAssigneeId {
                                Text(getAssigneeName(assigneeId))
                                    .font(.body)
                                    .foregroundColor(.primary)
                            } else {
                                Text("选择负责人...")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedAssigneeId != nil {
                                Button(action: {
                                    selectedAssigneeId = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "person.circle")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let assigneeId = currentTask.assigneeId {
                            Text(getAssigneeName(assigneeId))
                                .font(.body)
                                .foregroundColor(.primary)
                        } else {
                            Text("未分配")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // Priority and Category (for editing)
            if isEditing {
                HStack(spacing: 16) {
                    // Priority
                    VStack(alignment: .leading, spacing: 8) {
                        Text("优先级")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Picker("优先级", selection: $editedPriority) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Text(priorityDisplayName(priority))
                                    .tag(priority)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("类别")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingCategoryPicker = true
                        }) {
                            HStack {
                                Text(getCurrentCategoryDisplayName())
                                    .font(.body)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
            } else {
                // Category display (非编辑模式)
                VStack(alignment: .leading, spacing: 8) {
                    Text("类别")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(getCurrentCategoryDisplayName())
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // 会议时间信息（如果是时间段任务）
                if currentTask.isTimeRangeTask {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("会议时间")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let startTime = currentTask.startTime {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.circle")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                    
                                    Text("开始时间: \(formatDateTime(startTime))")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            if let endTime = currentTask.endTime {
                                HStack(spacing: 8) {
                                    Image(systemName: "stop.circle")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                    
                                    Text("结束时间: \(formatDateTime(endTime))")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            if let duration = currentTask.duration {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    
                                    Text("会议时长: \(duration)")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Project Section
    private var projectSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("关联项目")
                .font(.headline)
                .fontWeight(.semibold)
            
            if isEditing {
                Button(action: {
                    showingProjectPicker = true
                }) {
                    HStack {
                        if let projectId = selectedProjectId,
                           let project = dataManager.getProject(byId: projectId) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(hex: project.color))
                                    .frame(width: 12, height: 12)
                                
                                Text(project.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        } else {
                            Text("选择项目...")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            } else {
                if let project = associatedProject {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: project.color))
                            .frame(width: 16, height: 16)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.name)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            if let description = project.description {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        Text(project.statusDisplayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: project.statusColor))
                            .cornerRadius(12)
                    }
                    .padding(12)
                    .background(Color(hex: project.color).opacity(0.05))
                    .cornerRadius(8)
                } else {
                    Text("无关联项目")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Metadata Section
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("任务信息")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Created Date
                HStack {
                    Text("创建时间")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatDateTime(currentTask.createdAt))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                if currentTask.updatedAt != currentTask.createdAt {
                    // Updated Date
                    HStack {
                        Text("更新时间")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatDateTime(currentTask.updatedAt))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button("删除任务") {
                deleteTask()
            }
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.red)
            .cornerRadius(12)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Supporting Views
    
    private var datePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "选择截止时间",
                    selection: $editedDueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("设置截止时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        showingDatePicker = false
                    }
                }
            }
        }
    }
    
    private var startTimePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "选择开始时间",
                    selection: Binding(
                        get: { editedStartTime ?? Date() },
                        set: { editedStartTime = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("设置开始时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        showingStartTimePicker = false
                    }
                }
            }
        }
    }
    
    private var endTimePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "选择结束时间",
                    selection: Binding(
                        get: { editedEndTime ?? editedStartTime ?? Date() },
                        set: { editedEndTime = $0 }
                    ),
                    in: (editedStartTime ?? Date())...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("设置结束时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        showingEndTimePicker = false
                    }
                }
            }
        }
    }

    private var projectPickerSheet: some View {
        NavigationView {
            List {
                Button("无项目") {
                    selectedProjectId = nil
                    showingProjectPicker = false
                }
                .foregroundColor(.primary)
                
                ForEach(dataManager.allProjects) { project in
                    Button(action: {
                        selectedProjectId = project.id
                        showingProjectPicker = false
                    }) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: project.color))
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                if let description = project.description {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedProjectId == project.id {
                                Image(systemName: "checkmark")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("选择项目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        showingProjectPicker = false
                    }
                }
            }
        }
    }
    
    private var assigneePickerSheet: some View {
        NavigationView {
            List {
                Button("无负责人") {
                    selectedAssigneeId = nil
                    showingAssigneePicker = false
                }
                .foregroundColor(.primary)
                
                ForEach(dataManager.getAllUsers()) { user in
                    Button(action: {
                        selectedAssigneeId = user.id
                        showingAssigneePicker = false
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: user.avatar ?? "person.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                if let role = user.role {
                                    Text(role)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if user.isOnline {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                            }
                            
                            if selectedAssigneeId == user.id {
                                Image(systemName: "checkmark")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("选择负责人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        showingAssigneePicker = false
                    }
                }
            }
        }
    }
    
    private var categoryPickerSheet: some View {
        NavigationView {
            List {
                ForEach(dataManager.getAllCategories(), id: \.category) { categoryPair in
                    Button(action: {
                        if categoryPair.category == .custom {
                            editedCategory = .custom
                            selectedCustomCategoryId = categoryPair.custom?.id
                        } else {
                            editedCategory = categoryPair.category
                            selectedCustomCategoryId = nil
                        }
                        showingCategoryPicker = false
                    }) {
                        HStack(spacing: 12) {
                            if let customCategory = categoryPair.custom {
                                // 自定义类别
                                Image(systemName: customCategory.icon)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: customCategory.color))
                                    .frame(width: 20, height: 20)
                                
                                Text(customCategory.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            } else {
                                // 默认类别
                                Image(systemName: "folder")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .frame(width: 20, height: 20)
                                
                                Text(categoryPair.category.displayName)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            if (categoryPair.category == editedCategory && 
                                categoryPair.custom?.id == selectedCustomCategoryId) {
                                Image(systemName: "checkmark")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // 添加自定义类别按钮
                Button(action: {
                    showingCategoryPicker = false
                    // 创建示例自定义类别
                    let customCategory = CustomTaskCategory(
                        name: "自定义\(dataManager.customCategories.count + 1)",
                        color: "#FF6B6B",
                        icon: "star.fill"
                    )
                    dataManager.addCustomCategory(customCategory)
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .frame(width: 20, height: 20)
                        
                        Text("添加自定义类别")
                            .font(.body)
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("选择类别")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        showingCategoryPicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func initializeEditingState() {
        editedTitle = currentTask.title
        editedDescription = currentTask.description
        editedStartTime = currentTask.startTime
        editedEndTime = currentTask.endTime
        editedDueDate = currentTask.dueDate ?? Date()
        editedPriority = currentTask.priority
        editedCategory = currentTask.category
        selectedCustomCategoryId = currentTask.customCategoryId
        selectedProjectId = currentTask.projectId
        selectedAssigneeId = currentTask.assigneeId
        isCompleted = currentTask.isCompleted
    }
    
    private func startEditing() {
        initializeEditingState()
        isEditing = true
    }
    
    private func cancelEditing() {
        initializeEditingState()
        isEditing = false
    }
    
    private func saveChanges() {
        let updatedTask = currentTask.updating(
            title: editedTitle,
            description: editedDescription,
            startTime: editedStartTime,
            endTime: editedEndTime,
            dueDate: editedDueDate,
            priority: editedPriority,
            category: editedCategory,
            customCategoryId: selectedCustomCategoryId,
            projectId: selectedProjectId,
            assigneeId: selectedAssigneeId
        )
        
        dataManager.updateTask(updatedTask)
        isEditing = false
    }
    
    private func toggleCompletion() {
        dataManager.toggleTaskCompletion(currentTask)
    }
    
    private func deleteTask() {
        dataManager.deleteTask(currentTask)
        dismiss()
    }
    
    // MARK: - Helper Views
    
    private func priorityBadge(_ priority: TaskPriority) -> some View {
        Text(priorityDisplayName(priority))
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priorityColor(priority))
            .cornerRadius(12)
    }
    
    // MARK: - Formatting Methods
    
    private func formatDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func formatCompletionTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
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
    
    private func getDueDateColor(_ date: Date) -> Color {
        if isTaskOverdue(date) {
            return .red
        } else if isTaskDueSoon(date) {
            return .orange
        } else {
            return .primary
        }
    }
    
    private func isTaskOverdue(_ date: Date) -> Bool {
        return Date() > date
    }
    
    private func isTaskDueSoon(_ date: Date) -> Bool {
        let timeInterval = date.timeIntervalSince(Date())
        return timeInterval > 0 && timeInterval < 24 * 60 * 60 // Due within 24 hours
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
    
    /// 获取当前类别的显示名称
    private func getCurrentCategoryDisplayName() -> String {
        if currentTask.category == .custom, let customCategoryId = currentTask.customCategoryId {
            return dataManager.getCustomCategory(byId: customCategoryId)?.name ?? "自定义"
        } else {
            return currentTask.category.displayName
        }
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
    TaskDetailView(task: Task(
        title: "用户注册系统开发",
        description: "开发用户注册、登录、密码重置等核心功能",
        dueDate: Date(),
        priority: .high,
        category: .development
    ))
} 