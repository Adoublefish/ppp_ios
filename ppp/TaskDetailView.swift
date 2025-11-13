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
    @State private var ocrResult: OCRResult?
    @State private var showingOCREditor = false
    @State private var suggestedTitle = ""
    @State private var suggestedDescription = ""
    @State private var showingFullScreenImage = false
    
    // Computed properties
    private var currentTask: Task {
        dataManager.allTasks.first { $0.id == task.id } ?? task
    }
    
    private var associatedProject: Project? {
        guard let projectId = currentTask.projectId else { return nil }
        return dataManager.getProject(byId: projectId)
    }
    
    private var assigneeDisplayName: String {
        guard let assigneeId = currentTask.assigneeId else {
            return "未分配"
        }
        return getAssigneeName(assigneeId)
    }
    
    private var descriptionDisplayText: String {
        currentTask.description.isEmpty ? "暂无描述" : currentTask.description
    }
    
    private var deadlineDisplayText: String {
        guard let dueDate = currentTask.dueDate else {
            return "No deadline"
        }
        return formatDueDateShort(dueDate)
    }
    
    private var deadlineDisplayColor: Color {
        currentTask.dueDate.map(getDueDateColor) ?? .secondary
    }
    
    private var deadlineDetailText: String {
        guard let dueDate = currentTask.dueDate else {
            return "无截止时间"
        }
        return formatDateTime(dueDate)
    }
    
    private var hasDueDate: Bool {
        currentTask.dueDate != nil
    }
    
    private var meetingTimeDisplayText: String {
        let start = currentTask.startTime
        let end = currentTask.endTime
        
        switch (start, end) {
        case let (.some(start), .some(end)):
            return "\(formatMeetingTime(start)) - \(formatMeetingTime(end))"
        case let (.some(start), .none):
            return formatMeetingTime(start)
        default:
            return "未设置"
        }
    }
    
    var body: some View {
        ScrollView {
                VStack(spacing: 0) {
                    // Modern header section inspired by reference image
                    modernHeaderSection
                    
                    // Content sections
                    VStack(spacing: 16) {
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
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "取消" : "返回") {
                        if isEditing {
                            cancelEditing()
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(.neuTextPrimary)
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
                    .foregroundColor(.neuAccent)
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
        .sheet(isPresented: $showingOCREditor) {
            OCREditorView(
                ocrResult: ocrResult,
                suggestedTitle: $suggestedTitle,
                suggestedDescription: $suggestedDescription,
                onApply: { title, description in
                    editedTitle = title
                    editedDescription = description
                    showingOCREditor = false
                },
                onCancel: {
                    showingOCREditor = false
                }
            )
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
        .fullScreenCover(isPresented: $showingFullScreenImage) {
            if let selectedImage = selectedImage {
                FullScreenImageView(image: selectedImage)
            }
        }
    }
    
    // MARK: - Modern Header Section (inspired by reference image)
    private var modernHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(priorityColor(currentTask.priority))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(priorityDisplayName(currentTask.priority))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentTask.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let project = associatedProject {
                        Text(project.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                infoBadge(
                    icon: "person.crop.circle",
                    title: "Author",
                    value: assigneeDisplayName
                )
                
                infoBadge(
                    icon: "calendar",
                    title: "Due",
                    value: deadlineDisplayText,
                    valueColor: currentTask.dueDate.map(getDueDateColor) ?? .secondary
                )
            }
            
            Button(action: toggleCompletion) {
                HStack(spacing: 12) {
                    Image(systemName: currentTask.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(currentTask.isCompleted ? .green : .secondary)
                    
                    Text(currentTask.isCompleted ? "已完成" : "Mark as Complete")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(currentTask.isCompleted ? .green : .primary)
                    
                    Spacer()
                }
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            
            Divider()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Original Header Section (kept for compatibility)
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
            
            VStack(spacing: 0) {
                detailRow(title: "任务标题") {
                    Text(currentTask.title)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                dividerRow
                
                detailRow(title: "任务描述", alignLeading: true) {
                    Text(descriptionDisplayText)
                        .font(.body)
                        .foregroundColor(descriptionDisplayText == "暂无描述" ? .secondary : .primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                dividerRow
                
                detailRow(title: "截止时间") {
                    Text(deadlineDetailText)
                        .font(.body)
                        .foregroundColor(deadlineDisplayColor)
                        .multilineTextAlignment(.trailing)
                }
                
                dividerRow
                
                detailRow(title: "负责人") {
                    Text(assigneeDisplayName)
                        .font(.body)
                        .foregroundColor(assigneeDisplayName == "未分配" ? .secondary : .primary)
                }
                
                dividerRow
                
                detailRow(title: "类别") {
                    categoryChip(text: getCurrentCategoryDisplayName())
                }
                
                dividerRow
                
                detailRow(title: "会议时间", alignLeading: true) {
                    Text(meetingTimeDisplayText)
                        .font(.body)
                        .foregroundColor(meetingTimeDisplayText == "未设置" ? .secondary : .primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(.systemGray5))
                    )
            )
            
            if let imageData = currentTask.attachmentImageData,
               let uiImage = UIImage(data: imageData) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("附件图像")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                        .onTapGesture {
                            selectedImage = uiImage
                            showingFullScreenImage = true
                        }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
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
                
                // Estimated Hours (only for tasks with due date)
                if hasDueDate,
                   let estimatedHours = currentTask.estimatedHours,
                   estimatedHours > 0 {
                    HStack {
                        Text("预估工时")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.softTeal)
                            
                            Text("\(formatEstimatedTime(estimatedHours)) 小时")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Actual Hours (if completed and has actual hours)
                if hasDueDate,
                   currentTask.isCompleted,
                   let actualHours = currentTask.actualHours,
                   actualHours > 0 {
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
                                        Color.softTeal.opacity(0.5),
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
                                    Color.softTeal.opacity(0.5),
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
                            .foregroundColor(.softTeal)
                        
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
            photoOCRSection
            
            // Time Estimation Section (only when task has a due date)
            if hasDueDate {
                timeEstimationSection
            }
            
            // Delete button
            deleteButtonSection
        }
        .padding(.top, 20)
    }
    
    // MARK: - Photo OCR Section
    private var photoOCRSection: some View {
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
                                showingFullScreenImage = true
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
                        .frame(maxWidth: .infinity)
                    }
                    .neumorphicButton(color: .neuBackground, textColor: .neuAccent)
                    
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
                        VStack(alignment: .leading, spacing: 12) {
                            Text("识别结果:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            // 原始识别文本
                            Text(extractedText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                            
                            // 智能识别结果显示
                            if let result = ocrResult, !result.extractedInfo.title.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(.softPink)
                                        Text("智能识别结果")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                    }
                                    
                                    // 建议的标题
                                    if !result.extractedInfo.title.isEmpty {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("标题:")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            
                                            Text(result.extractedInfo.title)
                                                .font(.caption)
                                                .padding(6)
                                                .background(Color.softPink.opacity(0.1))
                                                .cornerRadius(4)
                                        }
                                    }
                                    
                                    // 建议的描述
                                    if !result.extractedInfo.description.isEmpty {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("描述:")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            
                                            Text(result.extractedInfo.description)
                                                .font(.caption2)
                                                .padding(6)
                                                .background(Color.orange.opacity(0.1))
                                                .cornerRadius(4)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.softPink.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            // 操作按钮
                            HStack(spacing: 8) {
                                if let result = ocrResult, !result.extractedInfo.title.isEmpty {
                                    Button("编辑") {
                                        showingOCREditor = true
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .neumorphicButton(color: .neuPastelPink, textColor: .white)
                                    
                                    Button("应用") {
                                        if !result.extractedInfo.title.isEmpty {
                                            editedTitle = result.extractedInfo.title
                                        }
                                        if !result.extractedInfo.description.isEmpty {
                                            editedDescription = result.extractedInfo.description
                                        }
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .neumorphicButton(color: .neuBackground, textColor: .neuPastelPink)
                                }
                                
                                Button("原文加入描述") {
                                    if !editedDescription.isEmpty {
                                        editedDescription += "\n\n" + extractedText
                                    } else {
                                        editedDescription = extractedText
                                    }
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .neumorphicButton(color: .neuBackground, textColor: .neuAccent)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Time Estimation Section
    private var timeEstimationSection: some View {
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
                            NeumorphicPillButton(
                                title: String(format: "%.1fh", hours),
                                color: .neuAccent,
                                isSelected: editedEstimatedHours == hours
                            ) {
                                editedEstimatedHours = hours
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Delete Button Section
    private var deleteButtonSection: some View {
        Button("删除任务") {
                deleteTask()
            }
            .font(.headline)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .neumorphicButton(color: .red.opacity(0.15), textColor: .red)
    }
    
    // MARK: - Supporting Views
    
    private var datePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "选择截止日期",
                    selection: $editedDueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("选择截止日期")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        showingDatePicker = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
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
                                    .foregroundColor(.softTeal)
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
                                .foregroundColor(.softTeal)
                            
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
                                    .foregroundColor(.softTeal)
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
                                    .foregroundColor(.softTeal)
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
                                    .foregroundColor(.softTeal)
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
                    let cleanText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
                    extractedText = cleanText
                    
                    // 创建OCR结果并进行智能分析
                    let result = OCRResult(originalText: cleanText)
                    ocrResult = result
                    
                    // 自动填充建议的标题和描述
                    suggestedTitle = result.extractedInfo.title
                    suggestedDescription = result.extractedInfo.description
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
            
            // Only prompt for actual hours when task has a due date and isn't a meeting
            if hasDueDate && currentTask.category != .meeting {
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
    
    private func infoBadge(icon: String, title: String, value: String, valueColor: Color = .primary) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.softTeal)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(valueColor)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }
    
    @ViewBuilder
    private func detailRow<Content: View>(title: String, alignLeading: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(minWidth: 70, alignment: .leading)
            
            Spacer(minLength: 16)
            
            content()
                .frame(maxWidth: .infinity, alignment: alignLeading ? .leading : .trailing)
        }
        .padding(.vertical, 12)
    }
    
    private var dividerRow: some View {
        Divider()
            .padding(.leading, 0)
    }
    
    private func categoryChip(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(.systemGray6))
            )
            .foregroundColor(.primary)
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
    
    private func formatDueDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private func formatMeetingTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
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
        case .urgent: return .softPink
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
