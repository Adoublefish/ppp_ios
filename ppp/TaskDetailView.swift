//
//  TaskDetailView.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import SwiftUI
import PhotosUI
import Vision

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
    @State private var editedEstimatedHours: Double = 0.5
    
    @State private var isEditing = false
    @State private var showingDatePicker = false
    @State private var showingStartTimePicker = false
    @State private var showingEndTimePicker = false
    @State private var showingProjectPicker = false
    @State private var showingAssigneePicker = false
    @State private var showingCategoryPicker = false
    @State private var showingTimeInput = false
    
    // Photo and OCR functionality
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var extractedText = ""
    @State private var isProcessingOCR = false
    @State private var showingPhotoOptions = false
    
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
                    
                    if isEditing {
                        // Editing interface with consistent layout
                        editingInterfaceSection
                    } else {
                        // Task Details (view mode)
                        taskDetailsSection
                        
                        // Project Association
                        projectSection
                        
                        // Metadata
                        metadataSection
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
        .sheet(isPresented: $showingTimeInput) {
            TaskTimeInputSheet(task: currentTask)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) { image in
                if let image = image {
                    processImageWithOCR(image)
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage) { image in
                if let image = image {
                    processImageWithOCR(image)
                }
            }
        }
        .actionSheet(isPresented: $showingPhotoOptions) {
            ActionSheet(
                title: Text("选择图片来源"),
                buttons: [
                    .default(Text("拍照")) { showingCamera = true },
                    .default(Text("从相册选择")) { showingImagePicker = true },
                    .cancel()
                ]
            )
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
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "textformat")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("任务标题")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    if isEditing {
                        Text("*")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    if isEditing && !editedTitle.isEmpty {
                        Text("\(editedTitle.count)/50")
                            .font(.caption2)
                            .foregroundColor(editedTitle.count > 45 ? .orange : .secondary)
                    }
                }
                
                if isEditing {
                    TextField("输入任务标题", text: $editedTitle)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            editedTitle.isEmpty ? 
                                            Color(.systemGray4) : 
                                            Color.blue.opacity(0.5),
                                            lineWidth: editedTitle.isEmpty ? 1 : 1.5
                                        )
                                )
                        )
                        .onChange(of: editedTitle) { _, newValue in
                            if newValue.count > 50 {
                                editedTitle = String(newValue.prefix(50))
                            }
                        }
                } else {
                    Text(currentTask.title)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "text.alignleft")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("任务描述")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if isEditing && !editedDescription.isEmpty {
                        Text("\(editedDescription.count)/500")
                            .font(.caption2)
                            .foregroundColor(editedDescription.count > 450 ? .orange : .secondary)
                    }
                }
                
                if isEditing {
                    ZStack(alignment: .topLeading) {
                        // Background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        editedDescription.isEmpty ? 
                                        Color(.systemGray4) : 
                                        Color.blue.opacity(0.5),
                                        lineWidth: editedDescription.isEmpty ? 1 : 1.5
                                    )
                            )
                            .frame(minHeight: 120)
                        
                        // Text Editor
                        TextEditor(text: $editedDescription)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .onChange(of: editedDescription) { _, newValue in
                                if newValue.count > 500 {
                                    editedDescription = String(newValue.prefix(500))
                                }
                            }
                        
                        // Placeholder
                        if editedDescription.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("描述任务详情、要求或项目背景...")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: editedDescription.isEmpty)
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
                
                // Estimated Hours
                if let estimatedHours = currentTask.estimatedHours, estimatedHours > 0 {
                    HStack {
                        Text("预估工时")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Text("\(formatEstimatedTime(estimatedHours)) 小时")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Actual Hours (if completed and has actual hours)
                if currentTask.isCompleted, let actualHours = currentTask.actualHours, actualHours > 0 {
                    HStack {
                        Text("实际工时")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("\(formatEstimatedTime(actualHours)) 小时")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Editing Interface Section
    private var editingInterfaceSection: some View {
        VStack(spacing: 20) {
            // Task Title and Description
            taskTitleAndDescriptionSection
            
            // Time Settings Section (similar to TaskInputView)
            timeSettingsSection
            
            // Project Selection Section
            projectSelectionSection
            
            // Assignee Selection Section
            assigneeSelectionSection
            
            // Category Selection Section
            categorySelectionSection
            
            // Enhanced editing features (Photo/OCR and Time Estimation)
            actionButtonsSection
        }
    }
    
    private var taskTitleAndDescriptionSection: some View {
        VStack(spacing: 16) {
            // Task Title
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "textformat")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("任务标题")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("*")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    if !editedTitle.isEmpty {
                        Text("\(editedTitle.count)/50")
                            .font(.caption2)
                            .foregroundColor(editedTitle.count > 45 ? .orange : .secondary)
                    }
                }
                
                TextField("输入任务标题", text: $editedTitle)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        editedTitle.isEmpty ? 
                                        Color(.systemGray4) : 
                                        Color.blue.opacity(0.5),
                                        lineWidth: editedTitle.isEmpty ? 1 : 1.5
                                    )
                            )
                    )
                    .onChange(of: editedTitle) { _, newValue in
                        if newValue.count > 50 {
                            editedTitle = String(newValue.prefix(50))
                        }
                    }
            }
            
            // Task Description
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "text.alignleft")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("任务描述")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !editedDescription.isEmpty {
                        Text("\(editedDescription.count)/500")
                            .font(.caption2)
                            .foregroundColor(editedDescription.count > 450 ? .orange : .secondary)
                    }
                }
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    editedDescription.isEmpty ? 
                                    Color(.systemGray4) : 
                                    Color.blue.opacity(0.5),
                                    lineWidth: editedDescription.isEmpty ? 1 : 1.5
                                )
                        )
                    
                    TextEditor(text: $editedDescription)
                        .font(.body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .onChange(of: editedDescription) { _, newValue in
                            if newValue.count > 500 {
                                editedDescription = String(newValue.prefix(500))
                            }
                        }
                    
                    if editedDescription.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("描述任务详情、要求或项目背景...")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                    }
                }
                .frame(minHeight: 100)
                .animation(.easeInOut(duration: 0.2), value: editedDescription.isEmpty)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var timeSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("时间设置")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Start Time
                if editedStartTime != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("开始时间")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingStartTimePicker = true
                        }) {
                            HStack {
                                Text(formatDateTime(editedStartTime ?? Date()))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // End Time
                if editedEndTime != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("结束时间")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingEndTimePicker = true
                        }) {
                            HStack {
                                Text(formatDateTime(editedEndTime ?? Date()))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Due Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("截止时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        HStack {
                            Text(formatDateTime(editedDueDate))
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var projectSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "folder")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("关联项目")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("(可选)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            Button(action: {
                showingProjectPicker = true
            }) {
                HStack(spacing: 12) {
                    if let projectId = selectedProjectId,
                       let project = dataManager.getProject(byId: projectId) {
                        Circle()
                            .fill(Color(hex: project.color))
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(project.name)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            if let description = project.description {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    } else {
                        Image(systemName: "folder.badge.plus")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("选择项目")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var assigneeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("负责人")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            Button(action: {
                showingAssigneePicker = true
            }) {
                HStack(spacing: 12) {
                    if let assigneeId = selectedAssigneeId,
                       let assignee = dataManager.getAllUsers().first(where: { $0.id == assigneeId }) {
                        Image(systemName: assignee.avatar ?? "person.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(assignee.name)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            if let role = assignee.role {
                                Text(role)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                        if assignee.isOnline {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                        }
                    } else {
                        Image(systemName: "person.badge.plus")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("选择负责人")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "tag")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("任务分类")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Category selection button
            Button(action: {
                showingCategoryPicker = true
            }) {
                HStack(spacing: 12) {
                    if let customCategory = selectedCustomCategoryId,
                       let category = dataManager.getCustomCategory(byId: customCategory) {
                        Image(systemName: category.icon)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: category.color))
                            .frame(width: 20, height: 20)
                        
                        Text(category.name)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    } else {
                        Image(systemName: editedCategory.iconName)
                            .font(.subheadline)
                            .foregroundColor(editedCategory.color)
                            .frame(width: 20, height: 20)
                        
                        Text(editedCategory.displayName)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Priority Selection - matching TaskInputView style
            VStack(alignment: .leading, spacing: 12) {
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
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Enhanced editing features
            VStack(spacing: 12) {
                // Photo and OCR Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("图片和OCR识别")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 150)
                            .cornerRadius(8)
                            .onTapGesture {
                                showingPhotoOptions = true
                            }
                    }
                    
                    Button(action: {
                        showingPhotoOptions = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                            Text(selectedImage == nil ? "添加图片" : "更换图片")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    if isProcessingOCR {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("正在识别图片内容...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    if !extractedText.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("识别结果:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(extractedText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                            
                            Button("将识别内容添加到描述") {
                                if !editedDescription.isEmpty {
                                    editedDescription += "\n\n" + extractedText
                                } else {
                                    editedDescription = extractedText
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                // Time Estimation Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("预估工时")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("预估工时:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Stepper(value: $editedEstimatedHours, in: 0.1...24.0, step: 0.5) {
                            Text("\(editedEstimatedHours, specifier: "%.1f") 小时")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Quick time buttons
                    HStack(spacing: 8) {
                        ForEach([0.5, 1.0, 2.0, 4.0, 8.0], id: \.self) { hours in
                            Button("\(hours, specifier: "%.1f")h") {
                                editedEstimatedHours = hours
                            }
                            .font(.caption)
                            .foregroundColor(editedEstimatedHours == hours ? .white : .blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(editedEstimatedHours == hours ? Color.blue : Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            
            // Delete button
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
        editedEstimatedHours = currentTask.estimatedHours ?? 0.5
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
            assigneeId: selectedAssigneeId,
            estimatedHours: editedEstimatedHours
        )
        
        dataManager.updateTask(updatedTask)
        isEditing = false
    }
    
    private func processImageWithOCR(_ image: UIImage) {
        isProcessingOCR = true
        
        // Convert UIImage to CGImage
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                self.isProcessingOCR = false
                self.extractedText = "图片处理失败，请重试"
            }
            return
        }
        
        // Create text recognition request
        let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            DispatchQueue.main.async {
                isProcessingOCR = false
                
                if let error = error {
                    print("OCR 识别出错: \(error.localizedDescription)")
                    extractedText = "文字识别失败，请重试"
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("没有检测到文本")
                    extractedText = "未检测到文字内容"
                    return
                }
                
                var recognizedText = ""
                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    recognizedText += topCandidate.string + "\n"
                }
                
                if recognizedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    extractedText = "未检测到文字内容，请确保图片清晰且包含文字"
                } else {
                    extractedText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                // Add success animation
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    // Animation will be handled by the UI
                }
            }
        }
        
        // Configure recognition parameters for better accuracy
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"] // 支持简体中文、繁体中文和英文
        textRecognitionRequest.usesLanguageCorrection = true
        
        // Create image request handler
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Perform OCR on background queue
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([textRecognitionRequest])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessingOCR = false
                    self.extractedText = "文字识别过程中出现错误: \(error.localizedDescription)"
                    print("执行文本识别请求时出错: \(error)")
                }
            }
        }
    }
    
    private func toggleCompletion() {
        if currentTask.isCompleted {
            // If already completed, just toggle back
            dataManager.toggleTaskCompletion(currentTask)
        } else {
            // If not completed, complete the task first
            dataManager.toggleTaskCompletion(currentTask)
            
            // Show time input for non-meeting tasks or meeting tasks without actual time
            if currentTask.category != .meeting || currentTask.actualHours == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingTimeInput = true
                }
            }
        }
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
    
    /// 格式化预估工时显示
    private func formatEstimatedTime(_ hours: Double) -> String {
        if hours < 1 {
            return String(format: "%.1f", hours)
        } else if hours.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", hours)
        } else {
            return String(format: "%.1f", hours)
        }
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
