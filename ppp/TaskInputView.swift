//
//  TaskInputView.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import SwiftUI
import PhotosUI

enum TaskType: String, CaseIterable {
    case meeting = "meeting"
    case deadline = "deadline"
    
    var displayName: String {
        switch self {
        case .meeting: return "会议任务"
        case .deadline: return "截止任务"
        }
    }
    
    var description: String {
        switch self {
        case .meeting: return "有明确开始和结束时间"
        case .deadline: return "只有截止日期"
        }
    }
}

struct TaskInputView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var selectedTab = 0 // 0: Manual, 1: OCR
    @State private var projectTitle = ""
    @State private var projectDescription = ""
    @State private var projectTag = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var extractedText = ""
    @State private var isProcessingOCR = false
    @State private var showingAIBreakdown = false
    @State private var showingTeamMemberManagement = false
    @State private var showingCategoryManagement = false
    
    // New state variables for enhanced task input
    @State private var taskType: TaskType = .deadline
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600) // 1 hour later
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var selectedAssignee: TeamMember?
    @State private var selectedCategory: TaskCategory = .development
    @State private var selectedCustomCategory: CustomTaskCategory?
    @State private var selectedPriority: TaskPriority = .medium
    
    // Available project suggestions based on existing projects
    private var availableProjects: [String] {
        return dataManager.allProjects.map { $0.name }
    }
    
    // Available team members
    private var availableAssignees: [TeamMember] {
        return dataManager.getAllUsers()
    }
    
    // Available categories (default + custom)
    private var availableCategories: [(category: TaskCategory, custom: CustomTaskCategory?)] {
        return dataManager.getAllCategories()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Tab Selection
            tabSelectionView
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    if selectedTab == 0 {
                        // Manual Input Tab
                        manualInputSection
                    } else {
                        // OCR Input Tab
                        ocrInputSection
                    }
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(Color(.systemGroupedBackground))
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
        .fullScreenCover(isPresented: $showingAIBreakdown) {
            AITaskBreakdownView(
                projectTitle: projectTitle,
                projectDescription: projectDescription,
                extractedText: extractedText,
                projectTag: projectTag,
                dataManager: dataManager
            )
        }
        .sheet(isPresented: $showingTeamMemberManagement) {
            TeamMemberManagementView()
        }
        .sheet(isPresented: $showingCategoryManagement) {
            CategoryManagementView()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("创建任务")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60) // Status bar
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Tab Selection View
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            // Manual Tab
            Button(action: {
                selectedTab = 0
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                    
                    Text("手动输入")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            
            // OCR Tab
            Button(action: {
                selectedTab = 1
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "camera")
                        .font(.title3)
                        .foregroundColor(selectedTab == 1 ? .blue : .secondary)
                    
                    Text("拍照识别")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == 1 ? .blue : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            // Tab indicator
            Rectangle()
                .fill(Color.blue)
                .frame(width: UIScreen.main.bounds.width / 2, height: 2)
                .offset(x: selectedTab == 0 ? -UIScreen.main.bounds.width / 4 : UIScreen.main.bounds.width / 4)
                .animation(.easeInOut(duration: 0.3), value: selectedTab),
            alignment: .bottom
        )
    }
    
    // MARK: - Manual Input Section
    private var manualInputSection: some View {
        VStack(spacing: 20) {
            // Project Title
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
                    
                    if !projectTitle.isEmpty {
                        Text("\(projectTitle.count)/50")
                            .font(.caption2)
                            .foregroundColor(projectTitle.count > 45 ? .orange : .secondary)
                    }
                }
                
                TextField("输入任务或项目标题", text: $projectTitle)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        projectTitle.isEmpty ? 
                                        Color(.systemGray4) : 
                                        Color.blue.opacity(0.5),
                                        lineWidth: projectTitle.isEmpty ? 1 : 1.5
                                    )
                            )
                    )
                    .onChange(of: projectTitle) { _, newValue in
                        // Limit to 50 characters
                        if newValue.count > 50 {
                            projectTitle = String(newValue.prefix(50))
                        }
                    }
            }
            
            // Project Description
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
                    
                    if !projectDescription.isEmpty {
                        Text("\(projectDescription.count)/500")
                            .font(.caption2)
                            .foregroundColor(projectDescription.count > 450 ? .orange : .secondary)
                    }
                }
                
                ZStack(alignment: .topLeading) {
                    // Background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    projectDescription.isEmpty ? 
                                    Color(.systemGray4) : 
                                    Color.blue.opacity(0.5),
                                    lineWidth: projectDescription.isEmpty ? 1 : 1.5
                                )
                        )
                        .frame(minHeight: 120)
                    
                    // Text Editor
                    TextEditor(text: $projectDescription)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .onChange(of: projectDescription) { _, newValue in
                            // Limit to 500 characters
                            if newValue.count > 500 {
                                projectDescription = String(newValue.prefix(500))
                            }
                        }
                    
                    // Placeholder with better styling
                    if projectDescription.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("描述任务详情、要求或项目背景...")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 16) {
                                Label("支持多行输入", systemImage: "text.alignleft")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Label("最多500字", systemImage: "textformat.123")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: projectDescription.isEmpty)
            }
            
            // Time Settings Section
            timeSettingsSection
            
            // Assignee Selection Section
            assigneeSelectionSection
            
            // Category Selection Section
            categorySelectionSection
            
            // Project Selection
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "folder")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("选择项目")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                // Project input field
                TextField("输入项目名称或选择现有项目", text: $projectTag)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        projectTag.isEmpty ? 
                                        Color(.systemGray4) : 
                                        Color.blue.opacity(0.5),
                                        lineWidth: projectTag.isEmpty ? 1 : 1.5
                                    )
                            )
                    )
                
                // Existing Projects
                VStack(alignment: .leading, spacing: 8) {
                    Text("现有项目")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(availableProjects, id: \.self) { project in
                                Button(action: {
                                    projectTag = project
                                }) {
                                    Text(project)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(projectTag == project ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                        .foregroundColor(projectTag == project ? .blue : .primary)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(projectTag == project ? Color.blue : Color.clear, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                // Create New Project Option
                if !projectTag.isEmpty && !availableProjects.contains(projectTag) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Text("创建新项目: \"\(projectTag)\"")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - OCR Input Section
    private var ocrInputSection: some View {
        VStack(spacing: 20) {
            // Image Upload/OCR Area
            VStack(spacing: 16) {
                if let selectedImage = selectedImage {
                    // Show selected image
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                        .onTapGesture {
                            showImagePickerOptions()
                        }
                } else {
                    // Upload area
                    Button(action: {
                        showImagePickerOptions()
                    }) {
                        VStack(spacing: 16) {
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 4) {
                                Text("点击上传图片")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text("支持自动OCR识别")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                .foregroundColor(.secondary)
                        )
                    }
                }
                
                // Camera and Gallery buttons
                HStack(spacing: 16) {
                    Button(action: {
                        showingCamera = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera")
                                .font(.subheadline)
                            Text("拍照")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.subheadline)
                            Text("相册")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                }
            }
            
            // Extracted Text (if available)
            if !extractedText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        
                        Text("识别结果")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("识别完成")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    
                    ScrollView {
                        Text(extractedText)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .frame(maxHeight: 120)
                }
                
                // Additional settings for OCR tasks
                VStack(spacing: 16) {
                    // Time Settings Section
                    timeSettingsSection
                    
                    // Assignee Selection Section
                    assigneeSelectionSection
                    
                    // Category Selection Section
                    categorySelectionSection
                }
            }
            
            // OCR Processing Indicator
            if isProcessingOCR {
                HStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text("正在识别图片内容...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 16)
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // AI Breakdown Button
            Button(action: {
                showingAIBreakdown = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.title3)
                    
                    Text("AI拆分任务")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
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
            .disabled(shouldDisableAIButton)
            .opacity(shouldDisableAIButton ? 0.6 : 1.0)
            
            // Direct Create Button
            Button(action: {
                createTaskDirectly()
            }) {
                Text("直接创建")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .disabled(shouldDisableCreateButton)
            .opacity(shouldDisableCreateButton ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Helper Properties
    private var shouldDisableAIButton: Bool {
        if selectedTab == 0 {
            return projectTitle.isEmpty && projectDescription.isEmpty
        } else {
            return extractedText.isEmpty
        }
    }
    
    private var shouldDisableCreateButton: Bool {
        if selectedTab == 0 {
            return projectTitle.isEmpty
        } else {
            return extractedText.isEmpty
        }
    }
    
    private func getTaskTitle() -> String {
        if selectedTab == 0 {
            return projectTitle
        } else {
            // For OCR, use projectTitle if available, otherwise use first line of extracted text
            if !projectTitle.isEmpty {
                return projectTitle
            } else {
                return extractedText.components(separatedBy: .newlines).first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "OCR任务"
            }
        }
    }
    
    private func getTaskDescription() -> String {
        if selectedTab == 0 {
            return projectDescription
        } else {
            // For OCR, combine projectDescription and extractedText
            if !projectDescription.isEmpty {
                return projectDescription + "\n\n识别内容:\n" + extractedText
            } else {
                return extractedText
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showImagePickerOptions() {
        let alert = UIAlertController(title: "选择图片", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "拍照", style: .default) { _ in
            showingCamera = true
        })
        
        alert.addAction(UIAlertAction(title: "从相册选择", style: .default) { _ in
            showingImagePicker = true
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            alert.popoverPresentationController?.sourceView = viewController.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            viewController.present(alert, animated: true)
        }
    }
    
    private func processImageWithOCR(_ image: UIImage) {
        isProcessingOCR = true
        
        // Simulate OCR processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Mock OCR result
            extractedText = """
            电商平台开发项目
            
            主要任务：
            1. 用户注册登录系统开发
            2. 商品展示和搜索功能
            3. 购物车和订单管理
            4. 支付系统集成
            5. 后台管理系统
            6. 移动端适配优化
            
            项目周期：8周
            截止时间：2024年4月15日
            负责人：开发团队
            """
            isProcessingOCR = false
        }
    }
    
    private func createTaskDirectly() {
        guard !getTaskTitle().isEmpty else { return }
        
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
        
        // Create task with enhanced fields
        let newTask = Task(
            title: getTaskTitle(),
            description: getTaskDescription(),
            startTime: taskType == .meeting ? startTime : nil,
            endTime: taskType == .meeting ? endTime : nil,
            dueDate: taskType == .deadline ? dueDate : nil,
            priority: selectedPriority,
            category: selectedCategory,
            customCategoryId: selectedCustomCategory?.id,
            projectId: selectedProjectId,
            assigneeId: selectedAssignee?.id
        )
        
        dataManager.addTask(newTask)
        dismiss()
    }
    
    // MARK: - Time Settings Section
    private var timeSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("时间设置")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Task Type Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("任务类型")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    ForEach(TaskType.allCases, id: \.self) { type in
                        Button(action: {
                            taskType = type
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(type.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(taskType == type ? .blue : .primary)
                                
                                Text(type.description)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(taskType == type ? Color.blue.opacity(0.1) : Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(taskType == type ? Color.blue : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            
            // Time Pickers based on task type
            if taskType == .meeting {
                VStack(spacing: 12) {
                    // Start Time
                    VStack(alignment: .leading, spacing: 4) {
                        Text("开始时间")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                            .onChange(of: startTime) { newStartTime in
                                // Ensure end time is at least 30 minutes after start time
                                if endTime <= newStartTime {
                                    endTime = newStartTime.addingTimeInterval(1800) // 30 minutes
                                }
                            }
                    }
                    
                    // End Time
                    VStack(alignment: .leading, spacing: 4) {
                        Text("结束时间")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $endTime, in: startTime..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                }
            } else {
                // Due Date for deadline tasks
                VStack(alignment: .leading, spacing: 4) {
                    Text("截止日期")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())
                }
            }
        }
    }
    
    // MARK: - Assignee Selection Section
    private var assigneeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("负责人")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    showingTeamMemberManagement = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.badge.plus")
                            .font(.caption)
                        Text("管理")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                }
            }
            
            // Current assignee display
            if let assignee = selectedAssignee {
                HStack(spacing: 12) {
                    Image(systemName: assignee.avatar ?? "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(assignee.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if let role = assignee.role {
                            Text(role)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button("更改") {
                        selectedAssignee = nil
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Assignee selection
            if selectedAssignee == nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("选择负责人")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // No assignee option
                            Button(action: {
                                selectedAssignee = nil
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "person.slash")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                    
                                    Text("无")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 60, height: 60)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            
                            // Available assignees
                            ForEach(availableAssignees) { assignee in
                                Button(action: {
                                    selectedAssignee = assignee
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: assignee.avatar ?? "person.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                        
                                        Text(assignee.name)
                                            .font(.caption2)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 60, height: 60)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }
        }
    }
    
    // MARK: - Category Selection Section
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("任务类别")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    showingCategoryManagement = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "tag.circle")
                            .font(.caption)
                        Text("管理")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                }
            }
            
            // Priority Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("优先级")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Button(action: {
                            selectedPriority = priority
                        }) {
                            Text(priorityDisplayName(priority))
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedPriority == priority ? priorityColor(priority).opacity(0.2) : Color(.systemGray6))
                                .foregroundColor(selectedPriority == priority ? priorityColor(priority) : .primary)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedPriority == priority ? priorityColor(priority) : Color.clear, lineWidth: 1)
                                )
                        }
                    }
                }
            }
            
            // Category Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("类别")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(availableCategories, id: \.category) { categoryItem in
                            Button(action: {
                                selectedCategory = categoryItem.category
                                selectedCustomCategory = categoryItem.custom
                            }) {
                                HStack(spacing: 6) {
                                    if let custom = categoryItem.custom {
                                        Image(systemName: custom.icon)
                                            .font(.caption2)
                                            .foregroundColor(isSelectedCategory(categoryItem) ? Color(hex: custom.color) : .secondary)
                                    } else {
                                        Image(systemName: categoryIcon(for: categoryItem.category))
                                            .font(.caption2)
                                            .foregroundColor(isSelectedCategory(categoryItem) ? categoryColor(for: categoryItem.category) : .secondary)
                                    }
                                    
                                    Text(categoryDisplayName(categoryItem))
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isSelectedCategory(categoryItem) ? getCategoryColor(categoryItem).opacity(0.1) : Color(.systemGray6))
                                .foregroundColor(isSelectedCategory(categoryItem) ? getCategoryColor(categoryItem) : .primary)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isSelectedCategory(categoryItem) ? getCategoryColor(categoryItem) : Color.clear, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
}

// MARK: - Helper Methods Extension
extension TaskInputView {
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
    
    private func categoryDisplayName(_ categoryItem: (category: TaskCategory, custom: CustomTaskCategory?)) -> String {
        if let custom = categoryItem.custom {
            return custom.name
        } else {
            return categoryItem.category.displayName
        }
    }
    
    private func isSelectedCategory(_ categoryItem: (category: TaskCategory, custom: CustomTaskCategory?)) -> Bool {
        if let custom = categoryItem.custom {
            return selectedCustomCategory?.id == custom.id
        } else {
            return selectedCategory == categoryItem.category && selectedCustomCategory == nil
        }
    }
    
    private func getCategoryColor(_ categoryItem: (category: TaskCategory, custom: CustomTaskCategory?)) -> Color {
        if let custom = categoryItem.custom {
            return Color(hex: custom.color)
        } else {
            return categoryColor(for: categoryItem.category)
        }
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
}

// MARK: - Supporting Views

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImageSelected: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                        self.parent.onImageSelected(image as? UIImage)
                    }
                }
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImageSelected: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImageSelected(image)
            }
            
            picker.dismiss(animated: true)
        }
    }
}

 