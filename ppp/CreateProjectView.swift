import SwiftUI

struct CreateProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    var onCreate: ((Project) -> Void)? = nil
    
    @State private var projectName: String = ""
    @State private var projectDescription: String = ""
    @State private var selectedOwner: OwnerOption = OwnerOption.personal
    @State private var showingOwnerSheet = false
    @State private var showAdvancedFields = false
    @State private var selectedColorHex: String = "#007AFF"
    
    private let colorOptions: [String] = [
        "#007AFF", "#34C759", "#FF9500", "#FF2D55",
        "#8E8E93", "#5856D6", "#64D2FF", "#FF9F0A"
    ]
    
    private var ownerOptions: [OwnerOption] {
        let defaultOptions: [OwnerOption] = [
            .personal,
            OwnerOption(id: UUID(), title: "💼 Work Team"),
            OwnerOption(id: UUID(), title: "🎓 CS Study Group")
        ]
        // Prefer actual teams if available
        if dataManager.teams.isEmpty {
            return defaultOptions
        } else {
            let teamOptions = dataManager.teams.map { team in
                OwnerOption(id: team.id, title: "👥 \(team.name)")
            }
            return [.personal] + teamOptions
        }
    }
    
    private var canCreate: Bool {
        !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    projectNameField
                    ownershipSelector
                    disclosureToggle
                    
                    if showAdvancedFields {
                        advancedFields
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("创建") {
                        createProject()
                    }
                    .disabled(!canCreate)
                    .foregroundColor(canCreate ? Color.accentPrimary : Color.textSecondary)
                    .fontWeight(.semibold)
                }
            }
            .confirmationDialog("选择归属", isPresented: $showingOwnerSheet, titleVisibility: .visible) {
                ForEach(ownerOptions) { option in
                    Button(option.title) {
                        selectedOwner = option
                    }
                }
                Button("取消", role: .cancel) { }
            }
        }
    }
    
    private var projectNameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .leading) {
                if projectName.isEmpty {
                    Text("项目名称 *")
                        .foregroundColor(Color.textSecondary)
                        .font(.system(size: 28, weight: .light))
                }
                
                TextField("", text: $projectName)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.textPrimary)
                    .keyboardType(.default)
            }
            .padding(.bottom, 4)
            
            Rectangle()
                .fill(Color.dividerLine)
                .frame(height: 1)
        }
    }
    
    private var ownershipSelector: some View {
        HStack(spacing: 6) {
            Text("归属于:")
                .font(.system(size: 16))
                .foregroundColor(.textSecondary)
            
            Button {
                showingOwnerSheet = true
            } label: {
                HStack(spacing: 6) {
                    Text(selectedOwner.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.backgroundSecondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.dividerLine, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
    
    private var disclosureToggle: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.25)) {
                showAdvancedFields.toggle()
            }
        }) {
            Text(showAdvancedFields ? "– 隐藏描述与颜色" : "+ 添加描述与颜色")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.accentPrimary)
        }
        .buttonStyle(.plain)
    }
    
    private var advancedFields: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("项目描述")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                
                TextEditor(text: $projectDescription)
                    .frame(height: 100)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.backgroundSecondary)
                    )
                    .foregroundColor(.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("项目颜色")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 12) {
                    ForEach(colorOptions, id: \.self) { colorHex in
                        let color = Color(hex: colorHex)
                        Circle()
                            .fill(color)
                            .frame(width: 34, height: 34)
                            .overlay(
                                Circle()
                                    .stroke(selectedColorHex == colorHex ? Color.textPrimary.opacity(0.2) : .clear, lineWidth: 3)
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedColorHex = colorHex
                                }
                            }
                    }
                }
            }
        }
    }
    
    private func createProject() {
        guard canCreate else { return }
        
        let trimmedDescription = projectDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptionValue = showAdvancedFields && !trimmedDescription.isEmpty ? trimmedDescription : nil
        
        let newProject = Project(
            name: projectName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: descriptionValue,
            startDate: Date(),
            status: .planning,
            ownerId: selectedOwner.id,
            color: selectedColorHex,
            totalTasks: 0,
            activeTasks: 0,
            completedTasks: 0,
            teamMembers: [],
            timeLogged: 0
        )
        
        dataManager.addProject(newProject)
        onCreate?(newProject)
        dismiss()
    }
}

private struct OwnerOption: Identifiable, Equatable {
    let id: UUID
    let title: String
    
    static let personal = OwnerOption(id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC") ?? UUID(),
                                      title: "👤 个人项目")
}
