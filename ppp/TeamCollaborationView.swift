//
//  TeamCollaborationView.swift
//  ppp
//
//  Created by Kiro on 8/11/25.
//

import SwiftUI







// MARK: - Main Team Collaboration View
struct TeamCollaborationView: View {
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var showingCreateTeam = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header - 优化顶部距离
            HStack {
                Text("团队协作")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8) // 大幅减少顶部距离
            .padding(.bottom, 4) // 减少底部距离
            .background(Color(.systemBackground))
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Invitations Section
                    if !dataManager.teamInvitations.isEmpty {
                        invitationsSection
                    }
                    
                    // My Teams Section
                    myTeamsSection
                    
                    // Create Team Section
                    createTeamSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 120) // Extra space for tab bar
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .background(Color(.systemBackground))
        .onAppear {
            // Team data is loaded automatically in TaskDataManager init
        }
        .sheet(isPresented: $showingCreateTeam) {
            CreateTeamView()
        }
    }
    
    // MARK: - Invitations Section
    private var invitationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Invitations", systemImage: "envelope")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(dataManager.teamInvitations.count) pending")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
            }
            
            ForEach(dataManager.teamInvitations) { invitation in
                InvitationCardView(invitation: invitation)
            }
        }
    }
    
    // MARK: - My Teams Section
    private var myTeamsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("My Teams", systemImage: "person.3.fill")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(dataManager.teams.count) teams")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(12)
            }
            
            ForEach(dataManager.teams) { team in
                TeamCardView(team: team)
            }
        }
    }
    
    // MARK: - Create Team Section
    private var createTeamSection: some View {
        Button(action: {
            showingCreateTeam = true
        }) {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                
                Text("Create New Team")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Start a new team and invite members to collaborate")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.blue.opacity(0.05))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Invitation Card View
struct InvitationCardView: View {
    let invitation: TeamInvitation
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(invitation.teamName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Invited by \(invitation.inviterName) • \(timeAgoString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text(invitation.teamDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack(spacing: 12) {
                Button("Accept") {
                    withAnimation(.spring()) {
                        dataManager.acceptInvitation(invitation.id)
                    }
                }
                .buttonStyle(AcceptButtonStyle())
                
                Button("Decline") {
                    withAnimation(.spring()) {
                        dataManager.declineInvitation(invitation.id)
                    }
                }
                .buttonStyle(DeclineButtonStyle())
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.blue.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: invitation.invitedAt, relativeTo: Date())
    }
}

// MARK: - Team Card View
struct TeamCardView: View {
    let team: Team
    @State private var showingTeamDetail = false
    
    var body: some View {
        Button(action: {
            showingTeamDetail = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Team Header - Title and Members only
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(team.icon)
                                .font(.title2)
                            
                            Text(team.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Team Members
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Members")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(team.members.count) members")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(Array(team.members.prefix(5).enumerated()), id: \.offset) { index, member in
                            MemberAvatarView(member: member, index: index)
                        }
                        
                        if team.members.count > 5 {
                            Text("+\(team.members.count - 5)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(width: 32, height: 32)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingTeamDetail) {
            TeamDetailView(team: team)
        }
    }
}

// MARK: - Supporting Views
struct MemberAvatarView: View {
    let member: TeamMember
    let index: Int
    
    private let colors: [Color] = [.blue, .green, .orange, .red, .purple]
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colors[index % colors.count])
                .frame(width: 32, height: 32)
            
            Text(String(member.name.prefix(2)).uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            

        }
    }
}

struct StatView: View {
    let number: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(number)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct ActivityRowView: View {
    let activity: TeamActivity
    
    var body: some View {
        HStack(spacing: 8) {
            Text(activity.icon)
                .font(.subheadline)
            
            Text(activity.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer()
            
            Text(timeAgoString)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: activity.timestamp, relativeTo: Date())
    }
}

struct ActionButton: View {
    let title: String
    let style: ActionButtonStyle
    
    enum ActionButtonStyle {
        case primary, secondary
    }
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(style == .primary ? Color.blue : Color(.systemGray5))
            )
            .foregroundColor(style == .primary ? .white : .primary)
    }
}

// MARK: - Button Styles
struct AcceptButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DeclineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Team Detail View
struct TeamDetailView: View {
    let team: Team
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var selectedTab = 0
    @State private var showingCreateProject = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                teamHeaderView
                
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("Members").tag(0)
                    Text("Calendar").tag(1)
                    Text("Projects").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                // Content
                TabView(selection: $selectedTab) {
                    teamMembersView.tag(0)
                    teamCalendarView.tag(1)
                    teamProjectsView.tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        // Handle settings
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateProject) {
            TaskInputView(team: team)
        }
    }
    
    private var teamHeaderView: some View {
        VStack(spacing: 16) {
            HStack {
                Text(team.icon)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(team.members.count) members")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(Color(.systemGroupedBackground))
    }
    
    private var teamCalendarView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("团队日历")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                
                // 团队任务列表
                VStack(alignment: .leading, spacing: 12) {
                    let teamTasks = dataManager.getTeamTasks(teamId: team.id)
                    
                    if teamTasks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("暂无团队任务")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("创建第一个团队任务来开始协作")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    } else {
                        ForEach(teamTasks) { task in
                            TeamTaskRowView(task: task, team: team)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
    }
    
    private var teamProjectsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Team Projects")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        showingCreateProject = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 16)
                
                // Team Projects List
                LazyVStack(spacing: 12) {
                    ForEach(dataManager.getTeamProjects(teamId: team.id)) { project in
                        TeamProjectCardView(project: project, team: team)
                    }
                    
                    if dataManager.getTeamProjects(teamId: team.id).isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("No Projects Yet")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text("Create your first team project to get started")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                showingCreateProject = true
                            }) {
                                Text("Create Project")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
    }
    
    private var teamMembersView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(team.members.enumerated()), id: \.offset) { index, member in
                    TeamMemberDetailRow(member: member, index: index)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
    

}

// MARK: - Team Task Row View
struct TeamTaskRowView: View {
    let task: Task
    let team: Team
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // 完成状态
            Button(action: {
                dataManager.toggleTaskCompletion(task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 任务内容
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                        .strikethrough(task.isCompleted)
                    
                    Spacer()
                    
                    // 完成状态标识
                    if task.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("已完成")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(task.isCompleted ? .secondary.opacity(0.7) : .secondary)
                        .lineLimit(2)
                        .strikethrough(task.isCompleted)
                }
                
                // 任务信息
                HStack(spacing: 8) {
                    // 负责人
                    if let assigneeId = task.assigneeId,
                       let assignee = team.members.first(where: { $0.id == assigneeId }) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text(assignee.name)
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                        .opacity(task.isCompleted ? 0.7 : 1.0)
                    }
                    
                    // 完成时间显示
                    if task.isCompleted, let completedAt = task.completedAt {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.badge.checkmark")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text("完成于 \(formatCompletionTime(completedAt))")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    // 截止日期
                    if let dueDate = task.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: task.isCompleted ? "clock.badge.checkmark" : "clock")
                                .font(.caption2)
                                .foregroundColor(task.isCompleted ? .green : getUrgencyColor(for: dueDate))
                            Text(formatDueDate(dueDate))
                                .font(.caption2)
                                .foregroundColor(task.isCompleted ? .green : getUrgencyColor(for: dueDate))
                        }
                        .opacity(task.isCompleted ? 0.8 : 1.0)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(task.isCompleted ? Color(.systemGray6) : Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .opacity(task.isCompleted ? 0.8 : 1.0)
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            return "今天"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now)!) {
            return "明天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }
    
    private func formatCompletionTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "今天 \(formatter.string(from: date))"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now)!) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "昨天 \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }
    
    private func getUrgencyColor(for dueDate: Date) -> Color {
        let calendar = Calendar.current
        let now = Date()
        let daysDifference = calendar.dateComponents([.day], from: now, to: dueDate).day ?? 0
        
        if daysDifference < 0 {
            return .red // 已过期
        } else if daysDifference == 0 {
            return .orange // 今天到期
        } else if daysDifference == 1 {
            return .yellow // 明天到期
        } else {
            return .secondary // 正常
        }
    }
}

// MARK: - Supporting Detail Views
struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Handle action
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TeamMemberDetailRow: View {
    let member: TeamMember
    let index: Int
    
    private let colors: [Color] = [.blue, .green, .orange, .red, .purple]
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(colors[index % colors.count])
                    .frame(width: 44, height: 44)
                
                Text(String(member.name.prefix(2)).uppercased())
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                

            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let role = member.role {
                    Text(role)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                

            }
            
            Spacer()
            
            Button(action: {
                // Handle member action
            }) {
                Image(systemName: "ellipsis")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct DetailedActivityRow: View {
    let activity: TeamActivity
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(activity.icon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text(fullTimeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private var fullTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: activity.timestamp)
    }
}

// MARK: - Create Team View
struct CreateTeamView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    @State private var teamName = ""
    @State private var teamDescription = ""
    @State private var selectedIcon = "person.3.fill"
    @State private var selectedColor = "#3B82F6"
    @State private var selectedMembers: Set<UUID> = []
    @State private var showingMemberSelection = false
    
    private let iconOptions = [
        "person.3.fill", "briefcase.fill", "book.fill", "gamecontroller.fill",
        "music.note", "paintbrush.fill", "camera.fill", "heart.fill",
        "star.fill", "flag.fill", "lightbulb.fill", "gear"
    ]
    
    private let colorOptions = [
        "#3B82F6", "#10B981", "#F59E0B", "#EF4444",
        "#8B5CF6", "#EC4899", "#06B6D4", "#84CC16"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Team Icon Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team Icon")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Button(action: {
                                    selectedIcon = icon
                                }) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? .white : Color(hex: selectedColor))
                                        .frame(width: 50, height: 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedIcon == icon ? Color(hex: selectedColor) : Color(hex: selectedColor).opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedIcon == icon ? Color(hex: selectedColor) : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Team Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team Color")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(colorOptions, id: \.self) { color in
                                Button(action: {
                                    selectedColor = color
                                }) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: color))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                        )
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .opacity(selectedColor == color ? 1 : 0)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Team Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Team Name")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("Enter team name", text: $teamName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Team Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("Describe your team's purpose", text: $teamDescription, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    // Team Members Selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Team Members")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("Add Members") {
                                showingMemberSelection = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        
                        if selectedMembers.isEmpty {
                            Text("No members selected. You will be added as the team owner.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(selectedMembers.compactMap { id in
                                        dataManager.getTeamMember(byId: id)
                                    }.enumerated()), id: \.offset) { index, member in
                                        SelectedMemberChip(member: member, index: index) {
                                            selectedMembers.remove(member.id)
                                        }
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                    }
                    
                    // Team Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preview")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TeamPreviewCard(
                            name: teamName.isEmpty ? "Team Name" : teamName,
                            description: teamDescription.isEmpty ? "Team description will appear here" : teamDescription,
                            icon: selectedIcon,
                            color: selectedColor,
                            memberCount: selectedMembers.count + 1 // +1 for the creator
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Create Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createTeam()
                    }
                    .disabled(teamName.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingMemberSelection) {
            MemberSelectionView(selectedMembers: $selectedMembers)
        }
    }
    
    private func createTeam() {
        // Get selected members
        let selectedTeamMembers = selectedMembers.compactMap { id in
            dataManager.getTeamMember(byId: id)
        }
        
        // Add creator as the first member if not already included
        var allMembers = selectedTeamMembers
        let currentUser = TeamMember(name: "Me", role: "Owner", isOnline: true)
        if !allMembers.contains(where: { $0.name == "Me" }) {
            allMembers.insert(currentUser, at: 0)
        }
        
        let newTeam = Team(
            name: teamName,
            description: teamDescription.isEmpty ? "No description provided" : teamDescription,
            icon: selectedIcon,
            color: selectedColor,
            members: allMembers,
            totalTasks: 0,
            activeTasks: 0,
            completedTasks: 0,
            recentActivity: [
                TeamActivity(
                    icon: "🎉",
                    description: "Team \"\(teamName)\" was created",
                    timestamp: Date()
                )
            ]
        )
        
        dataManager.addTeam(newTeam)
        dismiss()
    }
}



// MARK: - Supporting Views for Create Team

struct SelectedMemberChip: View {
    let member: TeamMember
    let index: Int
    let onRemove: () -> Void
    
    private let colors: [Color] = [.blue, .green, .orange, .red, .purple]
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(colors[index % colors.count])
                .frame(width: 24, height: 24)
                .overlay(
                    Text(String(member.name.prefix(1)).uppercased())
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            Text(member.name)
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct TeamPreviewCard: View {
    let name: String
    let description: String
    let icon: String
    let color: String
    let memberCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: color))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(memberCount) member\(memberCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: color).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: color).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct MemberSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    @Binding var selectedMembers: Set<UUID>
    @State private var showingAddMember = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search members", text: .constant(""))
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                // Add New Member Button
                Button(action: {
                    showingAddMember = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Add New Member")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 2]))
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                // Members List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(dataManager.getAllUsers()) { member in
                            MemberSelectionRow(
                                member: member,
                                isSelected: selectedMembers.contains(member.id)
                            ) {
                                if selectedMembers.contains(member.id) {
                                    selectedMembers.remove(member.id)
                                } else {
                                    selectedMembers.insert(member.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Select Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddMember) {
            QuickAddMemberView { newMember in
                dataManager.addTeamMember(newMember)
                selectedMembers.insert(newMember.id)
            }
        }
    }
}

struct MemberSelectionRow: View {
    let member: TeamMember
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Avatar
                Image(systemName: member.avatar ?? "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                // Member Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(member.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if let role = member.role {
                        Text(role)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickAddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    let onMemberAdded: (TeamMember) -> Void
    
    @State private var name = ""
    @State private var role = ""
    @State private var selectedAvatar = "person.circle.fill"
    
    private let avatarOptions = [
        "person.circle.fill", "person.crop.circle.fill", "person.crop.square.fill",
        "person.2.circle.fill", "person.3.circle.fill"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Avatar Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Avatar")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(avatarOptions, id: \.self) { avatar in
                                Button(action: {
                                    selectedAvatar = avatar
                                }) {
                                    Image(systemName: avatar)
                                        .font(.title)
                                        .foregroundColor(selectedAvatar == avatar ? .white : .blue)
                                        .frame(width: 50, height: 50)
                                        .background(selectedAvatar == avatar ? Color.blue : Color.blue.opacity(0.1))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(selectedAvatar == avatar ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                // Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter member name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Role Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Role (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter role", text: $role)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newMember = TeamMember(
                            name: name,
                            avatar: selectedAvatar,
                            role: role.isEmpty ? nil : role,
                            isOnline: false
                        )
                        onMemberAdded(newMember)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Team Project Views

struct TeamProjectCardView: View {
    let project: Project
    let team: Team
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let description = project.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(project.statusDisplayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: project.statusColor).opacity(0.2))
                        .foregroundColor(Color(hex: project.statusColor))
                        .cornerRadius(8)
                    
                    Text("Team: \(team.name)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(project.completedTasks)/\(project.totalTasks)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: project.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: project.color)))
            }
            
            // Team Members Preview
            HStack {
                Text("Team Members")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: -8) {
                    ForEach(Array(team.members.prefix(3).enumerated()), id: \.offset) { index, member in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(String(member.name.prefix(1)).uppercased())
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemBackground), lineWidth: 2)
                            )
                    }
                    
                    if team.members.count > 3 {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("+\(team.members.count - 3)")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                TeamProjectActionButton(
                    title: "Add Task",
                    icon: "plus.circle.fill",
                    color: .blue,
                    project: project,
                    team: team
                )
                
                TeamProjectActionButton(
                    title: "View Tasks",
                    icon: "list.bullet",
                    color: .green,
                    project: project,
                    team: team
                )
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct CreateTeamProjectView: View {
    let team: Team
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    @State private var projectName = ""
    @State private var projectDescription = ""
    @State private var selectedColor = "#3B82F6"
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    private let colorOptions = [
        "#3B82F6", "#10B981", "#F59E0B", "#EF4444",
        "#8B5CF6", "#EC4899", "#06B6D4", "#84CC16"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Project Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Project Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Project Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter project name", text: $projectName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter project description", text: $projectDescription, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                    }
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Project Color")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(colorOptions, id: \.self) { color in
                                Button(action: {
                                    selectedColor = color
                                }) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: color))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                        )
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .opacity(selectedColor == color ? 1 : 0)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Project Timeline")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        }
                    }
                    
                    // Team Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team Assignment")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text(team.icon)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(team.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("\(team.members.count) members")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Create Team Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createTeamProject()
                    }
                    .disabled(projectName.isEmpty)
                }
            }
        }
    }
    
    private func createTeamProject() {
        let newProject = Project(
            name: projectName,
            description: projectDescription.isEmpty ? nil : projectDescription,
            startDate: startDate,
            endDate: endDate,
            status: .planning,
            ownerId: team.id, // Use team ID as owner
            color: selectedColor,
            totalTasks: 0,
            activeTasks: 0,
            completedTasks: 0,
            teamMembers: team.members,
            timeLogged: 0
        )
        
        dataManager.addProject(newProject)
        dismiss()
    }
}

// MARK: - Team Project Action Button
struct TeamProjectActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let project: Project
    let team: Team
    
    @State private var showingCreateTask = false
    @State private var showingTaskList = false
    
    var body: some View {
        Button(action: {
            if title == "Add Task" {
                showingCreateTask = true
            } else if title == "View Tasks" {
                showingTaskList = true
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(8)
        }
        .sheet(isPresented: $showingCreateTask) {
            CreateTeamTaskView(project: project, team: team)
        }
        .sheet(isPresented: $showingTaskList) {
            TeamTaskListView(project: project, team: team)
        }
    }
}

// MARK: - Create Team Task View
struct CreateTeamTaskView: View {
    let project: Project
    let team: Team
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var selectedPriority = TaskPriority.medium
    @State private var selectedCategory = TaskCategory.development
    @State private var selectedAssignee: UUID?
    @State private var dueDate: Date?
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var hasDueDate = false
    @State private var hasTimeRange = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Project Info Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Creating task for")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(team.icon)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("Team: \(team.name)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: project.color).opacity(0.1))
                        )
                    }
                    
                    // Task Basic Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Task Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter task title", text: $taskTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter task description", text: $taskDescription, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                    }
                    
                    // Priority Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Priority")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 12) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Button(action: {
                                    selectedPriority = priority
                                }) {
                                    Text(priority.rawValue.capitalized)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedPriority == priority ? priorityColor(priority) : Color(.systemGray5))
                                        .foregroundColor(selectedPriority == priority ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(TaskCategory.defaultCategories, id: \.self) { category in
                                Text(category.displayName).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Assignee Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Assign to Team Member")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Unassigned option
                                Button(action: {
                                    selectedAssignee = nil
                                }) {
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(selectedAssignee == nil ? Color.blue : Color(.systemGray5))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "person.slash")
                                                    .font(.caption)
                                                    .foregroundColor(selectedAssignee == nil ? .white : .secondary)
                                            )
                                        
                                        Text("Unassigned")
                                            .font(.caption2)
                                            .foregroundColor(selectedAssignee == nil ? .blue : .secondary)
                                    }
                                }
                                
                                // Team members
                                ForEach(Array(team.members.enumerated()), id: \.offset) { index, member in
                                    Button(action: {
                                        selectedAssignee = member.id
                                    }) {
                                        VStack(spacing: 4) {
                                            Circle()
                                                .fill(selectedAssignee == member.id ? Color.blue : Color(.systemGray5))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Text(String(member.name.prefix(1)).uppercased())
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(selectedAssignee == member.id ? .white : .secondary)
                                                )
                                            
                                            Text(member.name)
                                                .font(.caption2)
                                                .foregroundColor(selectedAssignee == member.id ? .blue : .secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                    
                    // Due Date
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Due Date")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Toggle("", isOn: $hasDueDate)
                        }
                        
                        if hasDueDate {
                            DatePicker("Due Date", selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                        }
                    }
                    
                    // Time Range
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Time Range")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Toggle("", isOn: $hasTimeRange)
                        }
                        
                        if hasTimeRange {
                            VStack(spacing: 8) {
                                DatePicker("Start Time", selection: Binding(
                                    get: { startTime ?? Date() },
                                    set: { startTime = $0 }
                                ), displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                                
                                DatePicker("End Time", selection: Binding(
                                    get: { endTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: startTime ?? Date()) ?? Date() },
                                    set: { endTime = $0 }
                                ), displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Create Team Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createTeamTask()
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
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
    
    private func createTeamTask() {
        let newTask = Task(
            title: taskTitle,
            description: taskDescription,
            startTime: hasTimeRange ? startTime : nil,
            endTime: hasTimeRange ? endTime : nil,
            dueDate: hasDueDate ? dueDate : nil,
            priority: selectedPriority,
            category: selectedCategory,
            projectId: project.id,
            assigneeId: selectedAssignee
        )
        
        dataManager.addTask(newTask)
        
        // Update project task counts
        let updatedProject = Project(
            id: project.id,
            name: project.name,
            description: project.description,
            startDate: project.startDate,
            endDate: project.endDate,
            status: project.status,
            ownerId: project.ownerId,
            createdAt: project.createdAt,
            updatedAt: Date(),
            color: project.color,
            totalTasks: project.totalTasks + 1,
            activeTasks: project.activeTasks + 1,
            completedTasks: project.completedTasks,
            teamMembers: project.teamMembers,
            timeLogged: project.timeLogged
        )
        
        dataManager.updateProject(updatedProject)
        dismiss()
    }
}

// MARK: - Team Task List View
struct TeamTaskListView: View {
    let project: Project
    let team: Team
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    private var projectTasks: [Task] {
        dataManager.tasksForProject(project.id)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Project Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(team.icon)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(project.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Team: \(team.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(projectTasks.count) tasks")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            Text(project.statusDisplayName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Progress Bar
                    if project.totalTasks > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Progress")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("\(project.completedTasks)/\(project.totalTasks)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            ProgressView(value: project.progressPercentage)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: project.color)))
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemGroupedBackground))
                
                // Task List
                if projectTasks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checklist")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No Tasks Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Create your first task for this project")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(projectTasks) { task in
                                TeamTaskRowView(task: task, team: team)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Task") {
                        // This could open the create task view
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}



#Preview {
    TeamCollaborationView()
}