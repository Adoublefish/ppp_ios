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
            // Header
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("团队协作")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("管理并协同你的团队")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    showingCreateTeam = true
                } label: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                        .shadow(color: Color.blue.opacity(0.25), radius: 6, x: 0, y: 3)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    myTeamsSection
                    
                    if !dataManager.teamInvitations.isEmpty {
                        invitationsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .background(Color(.systemBackground))
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
                Label("待处理邀请", systemImage: "envelope")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Text("\(dataManager.teamInvitations.count) 个")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.blue.opacity(0.12)))
            }
            
            ForEach(dataManager.teamInvitations) { invitation in
                InvitationCardView(invitation: invitation)
            }
        }
    }
    
    // MARK: - My Teams Section
    private var myTeamsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if dataManager.teams.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.3.sequence")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("暂无团队")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("创建或加入团队以便协作。")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                VStack(spacing: 18) {
                    ForEach(dataManager.teams) { team in
                        TeamCardView(team: team)
                    }
                }
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
                    .foregroundColor(.softTeal)
                
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
                    .stroke(Color.softTeal.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.softTeal.opacity(0.05))
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
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                // Invitation Icon
                Image(systemName: "envelope.badge")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .frame(width: 48, height: 48)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(invitation.teamName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("来自 \(invitation.inviterName) 的邀请")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(timeAgoString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(invitation.teamDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack(spacing: 12) {
                Button("接受邀请") {
                    withAnimation(.spring()) {
                        dataManager.acceptInvitation(invitation.id)
                    }
                }
                .buttonStyle(AcceptButtonStyle())
                
                Button("拒绝") {
                    withAnimation(.spring()) {
                        dataManager.declineInvitation(invitation.id)
                    }
                }
                .buttonStyle(DeclineButtonStyle())
                
                Spacer()
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.orange.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
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
        Button {
            showingTeamDetail = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(hex: team.color).opacity(0.15))
                        .frame(width: 60, height: 60)
                    Image(systemName: team.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(hex: team.color))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(team.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\(team.members.count) 成员")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 18) {
                    VStack(spacing: 4) {
                        Text("\(team.activeTasks)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                        Text("活跃任务")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(team.completedTasks)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        Text("已完成")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingTeamDetail) {
            TeamDetailView(team: team)
        }
    }
}

// MARK: - Supporting Views
struct MemberAvatarView: View {
    let member: TeamMember
    let index: Int
    
    private let colors: [Color] = [.softTeal, .green, .orange, .red, .softPink]
    
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
                    .fill(style == .primary ? Color.softTeal : Color(.systemGray5))
            )
            .foregroundColor(style == .primary ? .white : .primary)
    }
}

// MARK: - Button Styles
struct AcceptButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green)
                    .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
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
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red, lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                    )
            )
            .foregroundColor(.red)
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
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                // Content
                TabView(selection: $selectedTab) {
                    teamMembersView.tag(0)
                    teamCalendarView.tag(1)
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
            CreateTeamProjectView(team: team)
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
                // Current date header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatCurrentDate())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("团队任务")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Display all team tasks grouped by date
                VStack(alignment: .leading, spacing: 16) {
                    let teamTasks = dataManager.getTeamTasks(teamId: team.id)
                    let groupedTasks = groupTasksByDate(teamTasks)
                    
                    if groupedTasks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("暂无团队任务")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("创建第一个团队任务")
                                .font(.subheadline)
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(Array(groupedTasks.keys.sorted()), id: \.self) { date in
                            VStack(alignment: .leading, spacing: 12) {
                                // Date section header
                                HStack {
                                    Text(formatSectionDate(date))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text("\(groupedTasks[date]?.count ?? 0) 个任务")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.secondary.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                // Tasks for this date
                                ForEach(groupedTasks[date] ?? []) { task in
                                    TeamTaskRowView(task: task, team: team)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }
    
    private func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func formatCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
    
    private func formatSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 (EEEE)"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func groupTasksByDate(_ tasks: [Task]) -> [Date: [Task]] {
        let calendar = Calendar.current
        var groupedTasks: [Date: [Task]] = [:]
        
        for task in tasks {
            guard let dueDate = task.dueDate else { continue }
            let dateKey = calendar.startOfDay(for: dueDate)
            
            if groupedTasks[dateKey] == nil {
                groupedTasks[dateKey] = []
            }
            groupedTasks[dateKey]?.append(task)
        }
        
        return groupedTasks
    }
    
    @State private var selectedCalendarDate = Date()
    
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
                                .foregroundColor(.softTeal)
                            Text(assignee.name)
                                .font(.caption2)
                                .foregroundColor(.softTeal)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.softTeal.opacity(0.1))
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
    
    private let colors: [Color] = [.softTeal, .green, .orange, .red, .softPink]
    
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
    @State private var showingIconPicker = false
    @State private var showAdvancedFields = false
    
    private let iconOptions = [
        "person.3.fill", "briefcase.fill", "book.fill", "gamecontroller.fill",
        "music.note", "paintbrush.fill", "camera.fill", "heart.fill",
        "star.fill", "flag.fill", "lightbulb.fill", "gear"
    ]
    
    private let colorOptions = [
        "#3B82F6", "#10B981", "#F59E0B", "#EF4444",
        "#8B5CF6", "#EC4899", "#06B6D4", "#84CC16"
    ]
    
    private var canCreate: Bool {
        !teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    teamNameField
                    iconAndColorRow
                    disclosureToggle
                    
                    if showAdvancedFields {
                        VStack(spacing: 16) {
                            descriptionField
                            memberSelectionField
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("创建") { createTeam() }
                        .fontWeight(.semibold)
                        .foregroundColor(canCreate ? .accentPrimary : .textSecondary)
                        .disabled(!canCreate)
                }
            }
        }
        .confirmationDialog("选择团队图标", isPresented: $showingIconPicker, titleVisibility: .visible) {
            ForEach(iconOptions, id: \.self) { icon in
                Button {
                    selectedIcon = icon
                } label: {
                    Text(Image(systemName: icon))
                }
            }
            Button("取消", role: .cancel) {}
        }
        .sheet(isPresented: $showingMemberSelection) {
            MemberSelectionView(selectedMembers: $selectedMembers)
        }
    }
    
    private var teamNameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .leading) {
                if teamName.isEmpty {
                    Text("团队名称 *")
                        .foregroundColor(.textSecondary)
                        .font(.system(size: 28, weight: .light))
                }
                
                TextField("", text: $teamName)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.textPrimary)
            }
            
            Rectangle()
                .fill(Color.dividerLine)
                .frame(height: 1)
        }
    }
    
    private var iconAndColorRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("视觉元素")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
            
            HStack(alignment: .center, spacing: 24) {
                Button {
                    showingIconPicker = true
                } label: {
                    VStack(spacing: 8) {
                        Text("图标")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Circle()
                            .fill(Color(hex: selectedColor).opacity(0.15))
                            .frame(width: 64, height: 64)
                            .overlay(
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(Color(hex: selectedColor))
                            )
                    }
                    .frame(width: 90)
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("颜色")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colorOptions, id: \.self) { color in
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 34, height: 34)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.textPrimary.opacity(0.3) : .clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var disclosureToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                showAdvancedFields.toggle()
            }
        } label: {
            Text(showAdvancedFields ? "– 隐藏描述与成员" : "+ 添加描述与成员")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.accentPrimary)
        }
        .buttonStyle(.plain)
    }
    
    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("团队描述")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
            
            TextEditor(text: $teamDescription)
                .frame(height: 100)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.backgroundSecondary)
                )
                .foregroundColor(.textPrimary)
        }
    }
    
    private var memberSelectionField: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("团队成员")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                Spacer()
                Button("管理") {
                    showingMemberSelection = true
                }
                .font(.caption)
                .foregroundColor(.accentPrimary)
            }
            
            if selectedMembers.isEmpty {
                Text("未选择成员，创建者将自动加入团队。")
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(selectedMembers.compactMap { dataManager.getTeamMember(byId: $0) }.enumerated()), id: \.offset) { index, member in
                            SelectedMemberChip(member: member, index: index) {
                                selectedMembers.remove(member.id)
                            }
                        }
                    }
                }
            }
        }
    }
    private func createTeam() {
        let name = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptionValue = showAdvancedFields ? teamDescription.trimmingCharacters(in: .whitespacesAndNewlines) : ""
        
        let selectedTeamMembers = selectedMembers.compactMap { id in
            dataManager.getTeamMember(byId: id)
        }
        var allMembers = selectedTeamMembers
        let currentUser = TeamMember(name: "Me", role: "Owner", isOnline: true)
        if !allMembers.contains(where: { $0.id == currentUser.id }) {
            allMembers.insert(currentUser, at: 0)
        }
        
        let newTeam = Team(
            name: name,
            description: descriptionValue.isEmpty ? "未填写团队描述" : descriptionValue,
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
    
    private let colors: [Color] = [.softTeal, .green, .orange, .red, .softPink]
    
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
                .fill(Color.backgroundSecondary)
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
                            .foregroundColor(.softTeal)
                        
                        Text("Add New Member")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.softTeal)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.softTeal.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.softTeal.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 2]))
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
                    .foregroundColor(.softTeal)
                    .frame(width: 40, height: 40)
                    .background(Color.softTeal.opacity(0.1))
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
                    .fill(isSelected ? Color.softTeal.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.softTeal : Color.clear, lineWidth: 1)
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
                                        .background(selectedAvatar == avatar ? Color.softTeal : Color.softTeal.opacity(0.1))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(selectedAvatar == avatar ? Color.softTeal : Color.clear, lineWidth: 2)
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
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
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
                                .fill(Color.softTeal)
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
                
            }
        }
        .foregroundColor(.primary)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .fullScreenCover(isPresented: $showingDetail) {
            ProjectDetailView(project: project)
        }
    }
}

struct CreateTeamProjectView: View {
    let team: Team
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    @State private var projectName = ""
    @State private var projectDescription = ""
    @State private var selectedColor = "#5DADE2"
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    private let colorOptions = [
        "#5DADE2", "#10B981", "#F59E0B", "#EF4444",
        "#FFB6B9", "#FFD6A5", "#A8E6CF", "#84CC16"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Project Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("项目信息")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.neuTextPrimary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("项目名称")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.neuTextSecondary)
                            
                            TextField("输入项目名称", text: $projectName)
                                .padding(12)
                                .background(Color.neuBackground)
                                .cornerRadius(12)
                                .neumorphicInset(cornerRadius: 12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("项目描述")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.neuTextSecondary)
                            
                            TextField("输入项目描述（可选）", text: $projectDescription, axis: .vertical)
                                .padding(12)
                                .background(Color.neuBackground)
                                .cornerRadius(12)
                                .lineLimit(3...6)
                                .neumorphicInset(cornerRadius: 12)
                        }
                    }
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("项目颜色")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.neuTextPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(colorOptions, id: \.self) { color in
                                Button(action: {
                                    selectedColor = color
                                }) {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.neuBackground, lineWidth: 4)
                                        )
                                        .overlay(
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .opacity(selectedColor == color ? 1 : 0)
                                        )
                                        .shadow(color: selectedColor == color ? Color(hex: color).opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
                                }
                            }
                        }
                    }
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("项目时间线")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.neuTextPrimary)
                        
                        VStack(spacing: 12) {
                            DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                                .foregroundColor(.neuTextPrimary)
                            DatePicker("结束日期", selection: $endDate, displayedComponents: .date)
                                .foregroundColor(.neuTextPrimary)
                        }
                    }
                    
                    // Team Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("所属团队")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.neuTextPrimary)
                        
                        HStack {
                            Text(team.icon)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(team.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.neuTextPrimary)
                                
                                Text("\(team.members.count) 成员")
                                    .font(.caption)
                                    .foregroundColor(.neuTextSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .neumorphicCard(cornerRadius: 12, padding: 0)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color.neuBackground)
            .navigationTitle("创建团队项目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.neuTextSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("创建") {
                        createTeamProject()
                    }
                    .foregroundColor(.neuAccent)
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
            TaskInputView(team: team, project: project)
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
                                            .fill(selectedAssignee == nil ? Color.softTeal : Color(.systemGray5))
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
                                                .fill(selectedAssignee == member.id ? Color.softTeal : Color(.systemGray5))
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
        case .urgent: return .softPink
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
                    .foregroundColor(.softTeal)
                }
            }
        }
    }
}

// MARK: - Team Calendar Vertical Date Strip
struct TeamCalendarVerticalDateStrip: View {
    @Binding var selectedDate: Date
    @State private var currentWeekDates: [Date] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Month and Year with navigation
            VStack(spacing: 8) {
                NeumorphicIconButton(
                    icon: "chevron.up",
                    size: 28,
                    iconSize: 12,
                    color: .neuBackground,
                    iconColor: .neuAccent,
                    action: {
                        moveWeek(by: -1)
                    }
                )
                
                Text(monthString)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.neuTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                NeumorphicIconButton(
                    icon: "chevron.down",
                    size: 28,
                    iconSize: 12,
                    color: .neuBackground,
                    iconColor: .neuAccent,
                    action: {
                        moveWeek(by: 1)
                    }
                )
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            
            Divider()
                .background(Color.neuTextTertiary.opacity(0.3))
            
            // Vertical dates strip
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(currentWeekDates, id: \.self) { date in
                        VerticalDateCell(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(date)
                        ) {
                            selectedDate = date
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
            }
        }
        .onAppear {
            generateCurrentWeek()
        }
    }
    
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }
    
    private func generateCurrentWeek() {
        let calendar = Calendar.current
        let today = selectedDate
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: today) else {
            return
        }
        
        var dates: [Date] = []
        var currentDate = weekInterval.start
        
        for _ in 0..<7 {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        currentWeekDates = dates
    }
    
    private func moveWeek(by weeks: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .weekOfYear, value: weeks, to: selectedDate) {
            selectedDate = newDate
            generateCurrentWeek()
        }
    }
    
    struct VerticalDateCell: View {
        let date: Date
        let isSelected: Bool
        let isToday: Bool
        let action: () -> Void
        
        private var dayString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
        
        private var dateString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        }
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Text(dateString)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .neuTextPrimary)
                    
                    Text(dayString)
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? .white : .neuTextSecondary)
                    
                    if isToday && !isSelected {
                        Circle()
                            .fill(Color.neuAccent)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(width: 64, height: 60)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.neuAccent, Color.neuAccent.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.neuAccent.opacity(0.3), radius: 6, x: 0, y: 3)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.neuBackground)
                        }
                    }
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}


#Preview {
    TeamCollaborationView()
}
