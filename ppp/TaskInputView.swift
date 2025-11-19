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
    case deadline = "deadline"
    case meeting = "meeting"
    
    var displayName: String {
        switch self {
        case .deadline: return "截止任务"
        case .meeting: return "会议任务"
        }
    }
    
    var description: String {
        switch self {
        case .deadline: return "只有截止日期"
        case .meeting: return "有开始和结束时间"
        }
    }
    
    var icon: String {
        switch self {
        case .deadline: return "flag.fill"
        case .meeting: return "calendar"
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
    @State private var ocrResult: OCRResult?
    @State private var showingFullScreenImage = false
    @State private var showingOCREditor = false
    @State private var suggestedTitle = ""
    @State private var suggestedDescription = ""
    @State private var showingAIBreakdown = false
    @State private var showingTeamMemberManagement = false
    @State private var showingCategoryManagement = false
    @State private var showingProjectPicker = false
    @State private var showingProjectCreation = false
    @State private var showingAssigneePicker = false
    @State private var showingCategoryPicker = false
    @State private var showingDueDateSheet = false
    
    // Enhanced task input variables
    @State private var taskType: TaskType = .deadline
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var hasDueDate = false
    @State private var hasTimeRange = false
    @State private var selectedAssignee: TeamMember?
    @State private var selectedCategory: TaskCategory = .development
    @State private var selectedCustomCategory: CustomTaskCategory?
    @State private var selectedPriority: TaskPriority? = nil
    @State private var estimatedHours: Double = 0.5
    @State private var recurrenceRule: RecurrenceRule = .none
    @State private var showingSuccessAlert = false
    @State private var selectedProjectId: UUID? = nil
    @State private var showAdvancedInputs = false
    @State private var showingStartTimePicker = false
    @State private var showingEndTimePicker = false
    @State private var pendingDueDate = Date()
    @State private var pendingEstimatedHours: Double = 0.5
    
    // 团队任务创建支持
    let team: Team?
    let project: Project?
    
    init(team: Team? = nil, project: Project? = nil) {
        self.team = team
        self.project = project
        _selectedProjectId = State(initialValue: project?.id)
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
    
    private var canCreateTask: Bool {
        !projectTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var canLaunchAIBreakdown: Bool {
        let hasManualText = !projectTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !projectDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasManualText || !extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func sectionCard<Content: View>(padding: CGFloat = 20, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.backgroundSecondary)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
    
    private func tabSelectionButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.accentPrimary : Color.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func dateSelectionButton(title: String, highlight: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: highlight ? .semibold : .regular))
                    .foregroundColor(highlight ? .accentPrimary : .textPrimary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.backgroundSecondary)
            )
        }
        .buttonStyle(.plain)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            tabSelectionView
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == 0 {
                            manualInputSection
                                .id("manualSection")
                            imageAttachmentSection
                        } else {
                            ocrInputSection
                        }
                        
                        actionButtonsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .background(Color.backgroundPrimary)
            }
        }
        .background(Color.backgroundPrimary)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) { image in
                if let image = image {
                    selectedImage = image
                    if selectedTab == 1 {
                        processImageWithOCR(image)
                    }
                } else {
                    clearSelectedImage()
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
        .fullScreenCover(isPresented: $showingFullScreenImage) {
            if let selectedImage = selectedImage {
                FullScreenImageView(image: selectedImage)
            }
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
        .sheet(isPresented: $showingDueDateSheet) {
            DueDateEditorSheet(
                initialDate: pendingDueDate,
                initialEstimatedHours: pendingEstimatedHours,
                onSave: { newDate, hours in
                    dueDate = newDate
                    estimatedHours = hours
                    hasDueDate = true
                },
                onClear: {
                    hasDueDate = false
                    estimatedHours = 0.5
                }
            )
            .presentationDetents([.fraction(0.55), .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingProjectCreation) {
            CreateProjectView { project in
                selectedProjectId = project.id
                showingProjectPicker = false
            }
        }
        .sheet(isPresented: $showingOCREditor) {
            OCREditorView(
                ocrResult: ocrResult,
                suggestedTitle: $suggestedTitle,
                suggestedDescription: $suggestedDescription,
                onApply: { title, description in
                    projectTitle = title
                    projectDescription = description
                    showingOCREditor = false
                },
                onCancel: {
                    showingOCREditor = false
                }
            )
        }
        .alert("任务创建成功", isPresented: $showingSuccessAlert) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("任务已成功创建并添加到项目中")
        }
        .sheet(isPresented: $showingStartTimePicker) {
            CustomCalendarPicker(selectedDate: $startTime, includeTime: true)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingEndTimePicker) {
            CustomCalendarPicker(selectedDate: $endTime, includeTime: true)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button("取消") {
                dismiss()
            }
            .foregroundColor(.softTeal)
            
            Spacer()
            
            Text(team != nil ? "Create Team Task" : "创建任务")
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
        HStack(spacing: 12) {
            tabSelectionButton(
                title: "手动输入",
                icon: "square.and.pencil",
                isSelected: selectedTab == 0
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 0
                }
            }
            
            tabSelectionButton(
                title: "拍照识别",
                icon: "camera.viewfinder",
                isSelected: selectedTab == 1
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 1
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    
    // MARK: - Manual Input Section
    private var manualInputSection: some View {
        VStack(spacing: 18) {
            titleCard
            dueDateCard
            timeRangeCard
            projectSelectionSection
            advancedToggleCard
            if showAdvancedInputs {
                advancedInputsSection.transition(.opacity)
            }
        }
    }
    
    private var ocrInputSection: some View {
        VStack(spacing: 18) {
            sectionCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.accentPrimary)
                        Text("拍照识别任务信息")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    
                    Text("拍摄或选择带文字的图片，自动识别任务标题与描述。")
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
                    
                    HStack(spacing: 12) {
                        Button {
                            showingCamera = true
                        } label: {
                            Label("打开相机", systemImage: "camera")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.accentPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            showingImagePicker = true
                        } label: {
                            Label("从相册选取", systemImage: "photo")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.accentPrimary.opacity(0.3), lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if let selectedImage = selectedImage {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 220)
                                .cornerRadius(12)
                                .onTapGesture {
                                    showingFullScreenImage = true
                                }
                            
                            HStack(spacing: 10) {
                                Button {
                                    showingImagePicker = true
                                } label: {
                                    Label("更换图片", systemImage: "photo.on.rectangle")
                                        .font(.system(size: 13, weight: .semibold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.accentPrimary.opacity(0.1))
                                        .foregroundColor(.accentPrimary)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    clearSelectedImage()
                                } label: {
                                    Label("移除图片", systemImage: "trash")
                                        .font(.system(size: 13, weight: .semibold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.red.opacity(0.1))
                                        .foregroundColor(.red)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                                
                                Spacer()
                                
                                if !isProcessingOCR {
                                    Button {
                                        if let image = self.selectedImage {
                                            processImageWithOCR(image)
                                        }
                                    } label: {
                                        Label("识别文字", systemImage: "wand.and.stars")
                                            .font(.system(size: 13, weight: .semibold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.purple.opacity(0.12))
                                            .foregroundColor(.purple)
                                            .cornerRadius(10)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    if isProcessingOCR {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.9, anchor: .center)
                            Text("正在识别图片内容…")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    if !extractedText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("识别内容")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            
                            Text(extractedText)
                                .font(.system(size: 13))
                                .foregroundColor(.textSecondary)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.backgroundSecondary)
                                )
                            
                            if let result = ocrResult {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(.purple)
                                        Text("智能提取建议")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.textSecondary)
                                    }
                                    
                                    if !result.extractedInfo.title.isEmpty {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("标题建议")
                                                .font(.caption2)
                                                .foregroundColor(.textSecondary)
                                            Text(result.extractedInfo.title)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.textPrimary)
                                                .padding(10)
                                                .background(Color.accentPrimary.opacity(0.08))
                                                .cornerRadius(10)
                                        }
                                    }
                                    
                                    if !result.extractedInfo.description.isEmpty {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("描述建议")
                                                .font(.caption2)
                                                .foregroundColor(.textSecondary)
                                            Text(result.extractedInfo.description)
                                                .font(.system(size: 13))
                                                .foregroundColor(.textPrimary)
                                                .padding(10)
                                                .background(Color.orange.opacity(0.08))
                                                .cornerRadius(10)
                                        }
                                    }
                                    
                                    HStack(spacing: 10) {
                                        Button {
                                            showingOCREditor = true
                                        } label: {
                                            Label("编辑结果", systemImage: "square.and.pencil")
                                                .font(.system(size: 13, weight: .semibold))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(10)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        Button {
                                            if !result.extractedInfo.title.isEmpty {
                                                projectTitle = result.extractedInfo.title
                                                projectTag = result.extractedInfo.title
                                            }
                                            if !result.extractedInfo.description.isEmpty {
                                                projectDescription = result.extractedInfo.description
                                            }
                                        } label: {
                                            Label("应用到表单", systemImage: "checkmark.circle")
                                                .font(.system(size: 13, weight: .semibold))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color.accentPrimary)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        Button {
                                            if !projectDescription.isEmpty {
                                                projectDescription += "\n" + extractedText
                                            } else {
                                                projectDescription = extractedText
                                            }
                                        } label: {
                                            Label("加入描述", systemImage: "text.badge.plus")
                                                .font(.system(size: 13, weight: .semibold))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(10)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button {
                let trimmedTitle = projectTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedTitle.isEmpty {
                    projectTag = trimmedTitle
                }
                showingAIBreakdown = true
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("AI智能拆分任务")
                        .fontWeight(.semibold)
                }
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.accentPrimary, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .buttonStyle(.plain)
            .disabled(!canLaunchAIBreakdown)
            .opacity(canLaunchAIBreakdown ? 1.0 : 0.4)
            
            Button {
                createTask()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("创建任务")
                        .fontWeight(.semibold)
                }
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.accentPrimary)
                .cornerRadius(16)
            }
            .buttonStyle(.plain)
            .disabled(!canCreateTask)
            .opacity(canCreateTask ? 1.0 : 0.4)
            
            if !canCreateTask {
                Text("请输入任务标题后再创建任务")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var titleCard: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text("任务标题")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("*")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    if !projectTitle.isEmpty {
                        Text("\(projectTitle.count)/50")
                            .font(.caption)
                            .foregroundColor(projectTitle.count > 45 ? .orange : .secondary)
                    }
                }
                
                TextField("输入任务或项目标题", text: $projectTitle)
                    .font(.system(size: 16))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.backgroundSecondary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(projectTitle.isEmpty ? Color(.systemGray4) : Color.accentPrimary.opacity(0.35), lineWidth: 1)
                    )
                    .onChange(of: projectTitle) { _, newValue in
                        if newValue.count > 50 {
                            projectTitle = String(newValue.prefix(50))
                        }
                    }
            }
        }
    }
    
    private var dueDateCard: some View {
        sectionCard {
            HStack(spacing: 16) {
                Text("截止日期")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button {
                    pendingDueDate = hasDueDate ? dueDate : Date()
                    pendingEstimatedHours = estimatedHours
                    showingDueDateSheet = true
                } label: {
                    dueDateSummaryView
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var timeRangeCard: some View {
        sectionCard {
            HStack {
                Text("Time Range")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Toggle("", isOn: $hasTimeRange)
                    .toggleStyle(SwitchToggleStyle(tint: .accentPrimary))
            }
            
            if hasTimeRange {
                Divider()
                    .padding(.vertical, 12)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("开始时间")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        dateSelectionButton(title: formatDateOnly(startTime), highlight: true) {
                            showingStartTimePicker = true
                        }
                        dateSelectionButton(title: formatTimeOnly(startTime)) {
                            showingStartTimePicker = true
                        }
                    }
                    
                    HStack {
                        Text("结束时间")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        dateSelectionButton(title: formatDateOnly(endTime), highlight: true) {
                            showingEndTimePicker = true
                        }
                        dateSelectionButton(title: formatTimeOnly(endTime)) {
                            showingEndTimePicker = true
                        }
                    }
                }
            }
        }
    }
    
    private var advancedToggleCard: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                showAdvancedInputs.toggle()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: showAdvancedInputs ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.accentPrimary)
                
                Text(showAdvancedInputs ? "收起高级选项" : "展开高级选项")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.accentPrimary)
                
                Spacer()
                
                if !showAdvancedInputs {
                    Text("描述、分类、负责人…")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.accentPrimary.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }
    
    private var advancedInputsSection: some View {
        VStack(spacing: 18) {
            sectionCard { taskDescriptionSection }
            sectionCard { categorySelectionSection }
            sectionCard { assigneeSelectionSection }
            sectionCard { simplifiedRecurrenceSection }
        }
    }

    private var taskDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("任务描述")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Spacer()
                if !projectDescription.isEmpty {
                    Text("\(projectDescription.count)/500")
                        .font(.caption)
                        .foregroundColor(projectDescription.count > 450 ? .orange : .secondary)
                }
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.backgroundSecondary)

                TextEditor(text: $projectDescription)
                    .font(.system(size: 15))
                    .foregroundColor(.textPrimary)
                    .padding(12)
                    .background(Color.clear)
                    .frame(minHeight: 120)
                    .overlay(
                        Group {
                            if projectDescription.isEmpty {
                                Text("填写任务描述")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                        }
                    )
                    .onChange(of: projectDescription) { _, newValue in
                        if newValue.count > 500 {
                            projectDescription = String(newValue.prefix(500))
                        }
                    }
            }
        }
    }

    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("分类")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Button("管理分类") { showingCategoryManagement = true }
                    .font(.caption)
                    .foregroundColor(.accentPrimary)
            }

            Button { showingCategoryPicker = true } label: {
                HStack(spacing: 12) {
                    if let custom = selectedCustomCategory {
                        Image(systemName: custom.icon)
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: custom.color))
                        Text(custom.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    } else {
                        Image(systemName: selectedCategory.iconName)
                            .font(.system(size: 18))
                            .foregroundColor(selectedCategory.color)
                        Text(selectedCategory.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.backgroundSecondary)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private var dueDateSummaryView: some View {
        if hasDueDate {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 15, weight: .semibold))
                Text("\(formatDateOnly(dueDate)) ・ \(formatTimeOnly(dueDate)) ・ 预计 \(formatEstimatedTime(estimatedHours))h")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.backgroundSecondary)
            )
        } else {
            HStack(spacing: 6) {
                Text("设置日期与工时")
                    .font(.system(size: 13, weight: .medium))
                Image(systemName: "bell")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.backgroundSecondary)
            )
        }
    }

    private var assigneeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("负责人")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Spacer()
                if let assignee = selectedAssignee {
                    Text(assignee.name)
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
            }

            Button { showingAssigneePicker = true } label: {
                HStack(spacing: 12) {
                    Image(systemName: selectedAssignee == nil ? "person.crop.circle.badge.plus" : (selectedAssignee?.avatar ?? "person.circle"))
                        .font(.system(size: 20))
                        .foregroundColor(.accentPrimary)
                    Text(selectedAssignee?.name ?? "选择负责人")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedAssignee == nil ? .accentPrimary : .textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.backgroundSecondary)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var simplifiedRecurrenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("任务循环")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textPrimary)

            HStack(spacing: 8) {
                ForEach(RecurrenceRule.allCases, id: \.self) { rule in
                    recurrenceChip(for: rule)
                }
            }

            if recurrenceRule != .none {
                Text(getRecurrenceDescription())
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
    }

    private var projectSelectionSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "folder")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.accentPrimary)

                    Text("关联项目")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)

                    Text("(可选)")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)

                    Spacer()

                    if let projectId = selectedProjectId,
                       let project = dataManager.getProject(byId: projectId) {
                        Text(project.name)
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }

                Button(action: { showingProjectPicker = true }) {
                    HStack(spacing: 14) {
                        if let projectId = selectedProjectId,
                           let project = dataManager.getProject(byId: projectId) {
                            Circle()
                                .fill(Color(hex: project.color))
                                .frame(width: 18, height: 18)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.textPrimary)
                                    .lineLimit(1)

                                if let description = project.description, !description.isEmpty {
                                    Text(description)
                                        .font(.system(size: 12))
                                        .foregroundColor(.textSecondary)
                                        .lineLimit(1)
                                }
                            }
                        } else {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.accentPrimary)

                            Text("选择项目")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.accentPrimary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.backgroundSecondary)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func recurrenceChip(for rule: RecurrenceRule) -> some View {
        Button {
            recurrenceRule = rule
        } label: {
            Text(rule.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(recurrenceRule == rule ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(recurrenceRule == rule ? Color.accentPrimary : Color.backgroundSecondary)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func recurrenceSelectionButton(for rule: RecurrenceRule) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                recurrenceRule = rule
            }
        } label: {
            Text(rule.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(recurrenceRule == rule ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(recurrenceRule == rule ? Color.softTeal : Color.white.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                        .shadow(
                            color: recurrenceRule == rule ? Color.softTeal.opacity(0.3) : Color.black.opacity(0.05),
                            radius: recurrenceRule == rule ? 6 : 3,
                            x: 0,
                            y: recurrenceRule == rule ? 3 : 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    private func formatDateOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private func formatTimeOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatEstimatedTime(_ hours: Double) -> String {
        if hours.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", hours)
        } else {
            return String(format: "%.1f", hours)
        }
    }
    
    private func getRecurrenceDescription() -> String {
        guard recurrenceRule != .none else {
            return "任务不会重复"
        }
        
        let calendar = Calendar.current
        let referenceDate: Date
        if hasDueDate {
            referenceDate = dueDate
        } else if hasTimeRange {
            referenceDate = startTime
        } else {
            referenceDate = Date()
        }
        
        switch recurrenceRule {
        case .daily:
            return "每天重复一次"
        case .weekly:
            let weekdaySymbols = calendar.weekdaySymbols
            let weekdayIndex = calendar.component(.weekday, from: referenceDate) - 1
            let weekday = weekdaySymbols.indices.contains(weekdayIndex) ? weekdaySymbols[weekdayIndex] : "每周"
            return "每周\(weekday)重复"
        case .monthly:
            let day = calendar.component(.day, from: referenceDate)
            return "每月\(day)日重复"
        case .yearly:
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            return "每年\(formatter.string(from: referenceDate))重复"
        case .none:
            return "任务不会重复"
        }
    }
    
    private func presentProjectCreationFlow() {
        showingProjectPicker = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showingProjectCreation = true
        }
    }
    
    // MARK: - Picker Sheets
    private var projectPickerSheet: some View {
        NavigationView {
            List {
                Button {
                    presentProjectCreationFlow()
                } label: {
                    Label("创建新项目", systemImage: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accentPrimary)
                        .padding(.vertical, 6)
                }
                
                Button("无项目") {
                    selectedProjectId = nil
                    showingProjectPicker = false
                }
                .foregroundColor(.textPrimary)
                
                // Show team projects first if creating a team task
                if let team = team {
                    let teamProjects = dataManager.getTeamProjects(teamId: team.id)
                    
                    if !teamProjects.isEmpty {
                        Section(header: Text("团队项目")) {
                            ForEach(teamProjects) { project in
                                ProjectPickerRow(
                                    project: project,
                                    isSelected: selectedProjectId == project.id,
                                    action: {
                                        selectedProjectId = project.id
                                        showingProjectPicker = false
                                    }
                                )
                            }
                        }
                    }
                    
                    // Other projects
                    let otherProjects = dataManager.allProjects.filter { $0.ownerId != team.id }
                    if !otherProjects.isEmpty {
                        Section(header: Text("其他项目")) {
                            ForEach(otherProjects) { project in
                                ProjectPickerRow(
                                    project: project,
                                    isSelected: selectedProjectId == project.id,
                                    action: {
                                        selectedProjectId = project.id
                                        showingProjectPicker = false
                                    }
                                )
                            }
                        }
                    }
                } else {
                    // Personal tasks - show all projects
                    ForEach(dataManager.allProjects) { project in
                        ProjectPickerRow(
                            project: project,
                            isSelected: selectedProjectId == project.id,
                            action: {
                                selectedProjectId = project.id
                                showingProjectPicker = false
                            }
                        )
                    }
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
                .foregroundColor(.textPrimary)
                
                ForEach(dataManager.getAllUsers()) { user in
                    Button(action: {
                        selectedAssignee = user
                        showingAssigneePicker = false
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: user.avatar ?? "person.circle.fill")
                                .font(.title3)
                                .foregroundColor(.softTeal)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.name)
                                    .font(.body)
                                    .foregroundColor(.textPrimary)
                                
                                if let role = user.role {
                                    Text(role)
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
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
                                    .foregroundColor(.softTeal)
                            }
                        }
                    }
                    .foregroundColor(.textPrimary)
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
                                    .foregroundColor(.textPrimary)
                            } else {
                                // 默认类别
                                Image(systemName: categoryPair.category.iconName)
                                    .font(.subheadline)
                                    .foregroundColor(categoryPair.category.color)
                                    .frame(width: 20, height: 20)
                                
                                Text(categoryPair.category.displayName)
                                    .font(.body)
                                    .foregroundColor(.textPrimary)
                            }
                            
                            Spacer()
                            
                            if (categoryPair.category == selectedCategory && 
                                categoryPair.custom?.id == selectedCustomCategory?.id) {
                                Image(systemName: "checkmark")
                                    .font(.subheadline)
                                    .foregroundColor(.softTeal)
                            }
                        }
                    }
                    .foregroundColor(.textPrimary)
                }
                
                // 添加自定义类别按钮
                Button(action: {
                    showingCategoryPicker = false
                    showingCategoryManagement = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle")
                            .font(.subheadline)
                            .foregroundColor(.softTeal)
                            .frame(width: 20, height: 20)
                        
                        Text("添加自定义类别")
                            .font(.body)
                            .foregroundColor(.softTeal)
                        
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
    
    // MARK: - Image Attachment Section
    private var imageAttachmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Text("附图")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                
                Spacer()
            }
            
            if let selectedImage = selectedImage {
                // 显示已选择的图片
                VStack(spacing: 12) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.caption)
                                Text("更换图片")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.softTeal.opacity(0.1))
                            .foregroundColor(.softTeal)
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            clearSelectedImage()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.caption)
                                Text("移除图片")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                }
            } else {
                // 添加图片按钮
                Button(action: {
                    showingImagePicker = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(.textSecondary)
                        
                        Text("添加附图")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.textSecondary)
                        
                        Text("点击选择图片")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Recurrence Selection Section
    private var recurrenceSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "repeat")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Text("任务循环")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                
                Spacer()
            }
            
            // 一行展示所有循环选项
            HStack(spacing: 8) {
                ForEach(RecurrenceRule.allCases, id: \.self) { rule in
                    recurrenceSelectionButton(for: rule)
                }
            }
            
            // 循环说明
            if recurrenceRule != .none {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text(getRecurrenceDescription())
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        )
    }
    
    private func processImageWithOCR(_ image: UIImage) {
        selectedImage = image
        isProcessingOCR = true
        extractedText = ""
        ocrResult = nil
        suggestedTitle = ""
        suggestedDescription = ""
        
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                self.isProcessingOCR = false
                self.extractedText = "图片无法识别，请尝试其他图片"
            }
            return
        }
        
        let textRecognitionRequest = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                self.isProcessingOCR = false
                
                if let error = error {
                    self.extractedText = "文字识别失败：\(error.localizedDescription)"
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                    self.extractedText = "未检测到文字内容，请确保图片清晰且包含文字"
                    return
                }
                
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                let cleanText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
                if cleanText.isEmpty {
                    self.extractedText = "未检测到文字内容，请确保图片清晰且包含文字"
                    return
                }
                
                self.extractedText = cleanText
                let result = OCRResult(originalText: cleanText)
                self.ocrResult = result
                self.suggestedTitle = result.extractedInfo.title
                self.suggestedDescription = result.extractedInfo.description
            }
        }
        
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"]
        textRecognitionRequest.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([textRecognitionRequest])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessingOCR = false
                    self.extractedText = "识别过程中出现错误：\(error.localizedDescription)"
                }
            }
        }
    }
    
    private func createTask() {
        guard canCreateTask else { return }
        
        let trimmedTitle = projectTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = projectDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let categoryToUse: TaskCategory = selectedCustomCategory != nil ? .custom : selectedCategory
        let customCategoryId = selectedCustomCategory?.id
        let dueDateValue = hasDueDate ? dueDate : nil
        
        var start: Date? = nil
        var end: Date? = nil
        if hasTimeRange {
            start = startTime
            end = max(endTime, startTime)
        }
        
        let attachmentData = selectedImage?.jpegData(compressionQuality: 0.75)
        
        let estimatedHoursValue: Double? = hasDueDate ? estimatedHours : nil
        
        let newTask = Task(
            title: trimmedTitle,
            description: trimmedDescription.isEmpty ? "未填写描述" : trimmedDescription,
            startTime: start,
            endTime: end,
            dueDate: dueDateValue,
            priority: selectedPriority ?? .medium,
            category: categoryToUse,
            customCategoryId: customCategoryId,
            projectId: selectedProjectId,
            assigneeId: selectedAssignee?.id,
            estimatedHours: estimatedHoursValue,
            recurrenceRule: recurrenceRule,
            attachmentImageData: attachmentData
        )
        
        dataManager.addTask(newTask)
        showingSuccessAlert = true
        clearForm()
    }
    
    private func clearForm() {
        projectTitle = ""
        projectDescription = ""
        projectTag = ""
        hasDueDate = false
        hasTimeRange = false
        dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        startTime = Date()
        endTime = Date().addingTimeInterval(3600)
        selectedAssignee = nil
        selectedCategory = .development
        selectedCustomCategory = nil
        selectedPriority = nil
        recurrenceRule = .none
        estimatedHours = 0.5
        selectedProjectId = project?.id
        showAdvancedInputs = false
        clearSelectedImage()
    }
    
    private func clearSelectedImage() {
        selectedImage = nil
        extractedText = ""
        ocrResult = nil
        suggestedTitle = ""
        suggestedDescription = ""
    }
}

// MARK: - Due Date Editor Sheet
private struct DueDateEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tempDate: Date
    @State private var tempEstimatedHours: Double
    let onSave: (Date, Double) -> Void
    let onClear: () -> Void
    
    init(initialDate: Date, initialEstimatedHours: Double, onSave: @escaping (Date, Double) -> Void, onClear: @escaping () -> Void) {
        _tempDate = State(initialValue: initialDate)
        _tempEstimatedHours = State(initialValue: initialEstimatedHours)
        self.onSave = onSave
        self.onClear = onClear
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("取消") {
                    dismiss()
                }
                .foregroundColor(.textSecondary)
                
                Spacer()
                
                Button("完成") {
                    onSave(tempDate, tempEstimatedHours)
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(.accentPrimary)
            }
            
            DatePicker("选择日期", selection: $tempDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .accentColor(.accentPrimary)
                .labelsHidden()
            
            Divider()
                .background(Color.dividerLine)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("选择时间")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                
                DatePicker("", selection: $tempDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("预计用时 (小时)")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 16) {
                    Button {
                        if tempEstimatedHours > 0.5 { tempEstimatedHours -= 0.5 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(tempEstimatedHours > 0.5 ? .accentPrimary : .gray.opacity(0.4))
                    }
                    .disabled(tempEstimatedHours <= 0.5)
                    
                    VStack(spacing: 2) {
                        Text(String(format: "%.1f", tempEstimatedHours))
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        Text("小时")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Button {
                        if tempEstimatedHours < 24 { tempEstimatedHours += 0.5 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(tempEstimatedHours < 24 ? .accentPrimary : .gray.opacity(0.4))
                    }
                    .disabled(tempEstimatedHours >= 24)
                    
                    Slider(value: $tempEstimatedHours, in: 0.5...24, step: 0.5)
                        .tint(.accentPrimary)
                }
            }
            
            Button("清除截止日期") {
                onClear()
                dismiss()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.red)
            .padding(.top, 12)
        }
        .padding(20)
        .presentationBackground(Color.backgroundPrimary)
    }
}

// MARK: - Project Picker Row
struct ProjectPickerRow: View {
    let project: Project
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: project.color))
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                    
                    if let description = project.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .foregroundColor(.softTeal)
                }
            }
        }
        .foregroundColor(.textPrimary)
    }
}


#Preview {
    TaskInputView()
}
