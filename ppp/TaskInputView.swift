//
//  TaskInputView.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import SwiftUI
import PhotosUI
import Vision

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
    @State private var showingProjectPicker = false
    @State private var showingAssigneePicker = false
    @State private var showingCategoryPicker = false
    
    // Enhanced task input variables
    @State private var taskType: TaskType = .deadline
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var selectedAssignee: TeamMember?
    @State private var selectedCategory: TaskCategory = .development
    @State private var selectedCustomCategory: CustomTaskCategory?
    @State private var selectedPriority: TaskPriority? = nil
    @State private var estimatedHours: Double = 0.5
    @State private var showingSuccessAlert = false
    @State private var selectedProjectId: UUID? = nil
    
    // 团队任务创建支持
    let team: Team?
    
    init(team: Team? = nil) {
        self.team = team
    }
    
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
                VStack(spacing: 20) {
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
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color.backgroundPrimary.opacity(0.3),
                    Color.backgroundSecondary
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
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
        .sheet(isPresented: $showingProjectPicker) {
            projectPickerSheet
        }
        .sheet(isPresented: $showingAssigneePicker) {
            assigneePickerSheet
        }
        .sheet(isPresented: $showingCategoryPicker) {
            categoryPickerSheet
        }
        .alert("任务创建成功", isPresented: $showingSuccessAlert) {
            Button("确定") {
                // Alert will dismiss automatically
            }
        } message: {
            Text("任务已成功创建并添加到项目中")
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button("取消") {
                dismiss()
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            Text(team != nil ? "创建团队任务" : "创建任务")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("取消")
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 6)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Tab Selection View
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            // Manual Tab
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 0
                }
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                    
                    Text("手动输入")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedTab == 0 ? Color.blue.opacity(0.1) : Color.clear)
                )
            }
            
            // OCR Tab
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 1
                }
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "camera")
                        .font(.title3)
                        .foregroundColor(selectedTab == 1 ? .blue : .secondary)
                    
                    Text("拍照识别")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == 1 ? .blue : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedTab == 1 ? Color.blue.opacity(0.1) : Color.clear)
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Manual Input Section
    private var manualInputSection: some View {
        VStack(spacing: 16) {
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
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    projectDescription.isEmpty ? 
                                    Color(.systemGray4) : 
                                    Color.blue.opacity(0.5),
                                    lineWidth: projectDescription.isEmpty ? 1 : 1.5
                                )
                        )
                    
                    TextEditor(text: $projectDescription)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .onChange(of: projectDescription) { _, newValue in
                            if newValue.count > 500 {
                                projectDescription = String(newValue.prefix(500))
                            }
                        }
                    
                    if projectDescription.isEmpty {
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
                .animation(.easeInOut(duration: 0.2), value: projectDescription.isEmpty)
            }
            
            // Time Settings Section
            timeSettingsSection
            
            // Assignee Selection Section
            assigneeSelectionSection
            
            // Category Selection Section
            categorySelectionSection
            
            // Project Selection
            projectSelectionSection
        }
    }
    
    // MARK: - OCR Input Section
    private var ocrInputSection: some View {
        VStack(spacing: 16) {
            // Image Upload/OCR Area
            VStack(spacing: 16) {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                        .onTapGesture {
                            showImagePickerOptions()
                        }
                } else {
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
                
                // Enhanced Camera and Gallery buttons
                HStack(spacing: 12) {
                    Button(action: {
                        showingCamera = true
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("拍照识别")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("选择图片")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                // Quick OCR tips
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 Vision OCR 使用提示:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("• 确保文字清晰可见，避免模糊")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("• 光线充足，避免阴影遮挡")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("• 支持中英文混合文档识别")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("• 识别效果最佳：印刷体文字")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            
            // Enhanced Extracted Text Section
            if !extractedText.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Vision OCR 识别结果")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("文字识别完成，可直接使用或编辑")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            
                            Text("已完成")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)
                    }
                    
                    // OCR result text with edit capability
                    VStack(alignment: .leading, spacing: 8) {
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
                                                .stroke(Color.green.opacity(0.3), lineWidth: 1.5)
                                        )
                                )
                        }
                        .frame(maxHeight: 150)
                        
                        // Quick action buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                projectTitle = extractedText.components(separatedBy: "\n").first ?? extractedText
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.doc")
                                        .font(.caption)
                                    Text("用作标题")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                projectDescription = extractedText
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.text")
                                        .font(.caption)
                                    Text("用作描述")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                extractedText = ""
                                selectedImage = nil
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "trash")
                                        .font(.caption)
                                    Text("清除")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                // Additional settings for OCR tasks
                VStack(spacing: 16) {
                    timeSettingsSection
                    assigneeSelectionSection
                    categorySelectionSection
                }
            }
            
            // Enhanced OCR Processing Indicator
            if isProcessingOCR {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vision 正在识别图片文字...")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("支持中英文混合识别，请稍候")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    // Processing steps indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.blue.opacity(0.7))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == 0 ? 1.2 : 0.8)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isProcessingOCR
                                )
                        }
                        
                        Text("图像处理 → Vision 文字识别 → 结果输出")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
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
                    RoundedRectangle(cornerRadius: 12)
                        .fill(shouldDisableAIButton ? Color.gray : Color.blue)
                )
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
                    .foregroundColor(shouldDisableCreateButton ? .secondary : .blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(shouldDisableCreateButton ? Color.clear : Color.blue, lineWidth: 1.5)
                            )
                    )
            }
            .disabled(shouldDisableCreateButton)
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
    
    private func createTaskDirectly() {
        guard !getTaskTitle().isEmpty else { return }
        
        // Find or create project
        var selectedProjectId: UUID? = nil
        if !projectTag.isEmpty {
            if let existingProject = dataManager.getProject(byName: projectTag) {
                selectedProjectId = existingProject.id
            } else {
                let ownerId = team?.id ?? UUID()
                let newProject = Project(
                    name: projectTag,
                    description: projectDescription.isEmpty ? nil : projectDescription,
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                    status: .active,
                    ownerId: ownerId,
                    color: team?.color ?? ["#3B82F6", "#F59E0B", "#10B981", "#8B5CF6", "#EF4444"].randomElement()!,
                    teamMembers: team?.members ?? []
                )
                dataManager.addProject(newProject)
                selectedProjectId = newProject.id
            }
        } else if let team = team {
            let defaultProjectName = "\(team.name) - 默认项目"
            if let existingProject = dataManager.getTeamProjects(teamId: team.id).first {
                selectedProjectId = existingProject.id
            } else {
                let newProject = Project(
                    name: defaultProjectName,
                    description: "团队默认项目",
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
                    status: .active,
                    ownerId: team.id,
                    color: team.color,
                    teamMembers: team.members
                )
                dataManager.addProject(newProject)
                selectedProjectId = newProject.id
            }
        }
        
        let newTask = Task(
            title: getTaskTitle(),
            description: getTaskDescription(),
            startTime: taskType == .meeting ? startTime : nil,
            endTime: taskType == .meeting ? endTime : nil,
            dueDate: taskType == .deadline ? dueDate : nil,
            priority: selectedPriority ?? .medium,
            category: selectedCategory,
            customCategoryId: selectedCustomCategory?.id,
            projectId: selectedProjectId,
            assigneeId: selectedAssignee?.id,
            estimatedHours: taskType == .meeting ? nil : estimatedHours
        )
        
        dataManager.addTask(newTask)
        showingSuccessAlert = true
        clearForm()
    }
    
    private func clearForm() {
        projectTitle = ""
        projectDescription = ""
        projectTag = ""
        selectedImage = nil
        extractedText = ""
        taskType = .deadline
        startTime = Date()
        endTime = Date().addingTimeInterval(3600)
        dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        selectedAssignee = nil
        selectedCategory = .development
        selectedCustomCategory = nil
        selectedPriority = nil
        estimatedHours = 0.5
        selectedProjectId = nil
    }
}

// MARK: - Time Settings Section
extension TaskInputView {
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
                
                Spacer()
            }
            
            // Task Type Selection
            HStack(spacing: 8) {
                ForEach(TaskType.allCases, id: \.self) { type in
                    Button(action: {
                        taskType = type
                    }) {
                        VStack(spacing: 4) {
                            Text(type.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(type.description)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(taskType == type ? .blue : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(taskType == type ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        )
                    }
                }
            }
            
            // Time Inputs based on task type
            if taskType == .meeting {
                VStack(spacing: 12) {
                    DatePicker("开始时间", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    DatePicker("结束时间", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())
                }
            } else {
                DatePicker("截止日期", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(CompactDatePickerStyle())
                
                // Estimated Hours
                VStack(alignment: .leading, spacing: 8) {
                    Text("预估工时")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            if estimatedHours > 0.5 {
                                estimatedHours -= 0.5
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(estimatedHours > 0.5 ? .blue : .gray)
                        }
                        .disabled(estimatedHours <= 0.5)
                        
                        VStack(spacing: 4) {
                            Text(formatEstimatedTime(estimatedHours))
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("小时")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(minWidth: 80)
                        
                        Button(action: {
                            if estimatedHours < 24 {
                                estimatedHours += 0.5
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(estimatedHours < 24 ? .blue : .gray)
                        }
                        .disabled(estimatedHours >= 24)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
            }
        }
    }
}

// MARK: - Assignee Selection Section
extension TaskInputView {
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
                        Image(systemName: "plus.circle")
                            .font(.caption)
                        Text("管理成员")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // Assignee selection button
            Button(action: {
                showingAssigneePicker = true
            }) {
                HStack(spacing: 12) {
                    if let assignee = selectedAssignee {
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
    }
}

// MARK: - Category Selection Section
extension TaskInputView {
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("任务分类")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    showingCategoryManagement = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .font(.caption)
                        Text("管理分类")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // Category selection button
            Button(action: {
                showingCategoryPicker = true
            }) {
                HStack(spacing: 12) {
                    if let customCategory = selectedCustomCategory {
                        Image(systemName: customCategory.icon)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: customCategory.color))
                            .frame(width: 20, height: 20)
                        
                        Text(customCategory.name)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    } else {
                        Image(systemName: selectedCategory.iconName)
                            .font(.subheadline)
                            .foregroundColor(selectedCategory.color)
                            .frame(width: 20, height: 20)
                        
                        Text(selectedCategory.displayName)
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
            
            // Priority Selection - matching TaskDetailView style
            VStack(alignment: .leading, spacing: 12) {
                Text("优先级")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                // Create a binding for the picker that handles both nil and TaskPriority values
                let priorityBinding = Binding<Int>(
                    get: {
                        if let priority = selectedPriority {
                            return TaskPriority.allCases.firstIndex(of: priority) ?? -1
                        } else {
                            return -1
                        }
                    },
                    set: { index in
                        if index == -1 {
                            selectedPriority = nil
                        } else if index < TaskPriority.allCases.count {
                            selectedPriority = TaskPriority.allCases[index]
                        }
                    }
                )
                
                Picker("优先级", selection: priorityBinding) {
                    Text("无").tag(-1)
                    ForEach(Array(TaskPriority.allCases.enumerated()), id: \.offset) { index, priority in
                        Text(priorityDisplayName(priority)).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    
    private func isSelectedCategory(_ item: (category: TaskCategory, custom: CustomTaskCategory?)) -> Bool {
        return selectedCategory == item.category && selectedCustomCategory?.id == item.custom?.id
    }
}

// MARK: - Project Selection Section
extension TaskInputView {
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
            
            // Project selection button
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
        case .medium: return .orange
        case .high: return .red
        case .urgent: return .purple
        }
    }
    
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

// MARK: - Picker Sheets
extension TaskInputView {
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
                    selectedAssignee = nil
                    showingAssigneePicker = false
                }
                .foregroundColor(.primary)
                
                ForEach(dataManager.getAllUsers()) { user in
                    Button(action: {
                        selectedAssignee = user
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
                            
                            if selectedAssignee?.id == user.id {
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
                            selectedCategory = .custom
                            selectedCustomCategory = categoryPair.custom
                        } else {
                            selectedCategory = categoryPair.category
                            selectedCustomCategory = nil
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
                                Image(systemName: categoryPair.category.iconName)
                                    .font(.subheadline)
                                    .foregroundColor(categoryPair.category.color)
                                    .frame(width: 20, height: 20)
                                
                                Text(categoryPair.category.displayName)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            if (categoryPair.category == selectedCategory && 
                                categoryPair.custom?.id == selectedCustomCategory?.id) {
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
                    showingCategoryManagement = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(width: 20, height: 20)
                        
                        Text("添加自定义类别")
                            .font(.body)
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("选择分类")
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
}

#Preview {
    TaskInputView()
}
