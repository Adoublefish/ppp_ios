//
//  TaskDataManager.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import Foundation
import SwiftUI

class TaskDataManager: ObservableObject {
    static let shared = TaskDataManager()
    
    @Published var allTasks: [Task] = []
    @Published var allProjects: [Project] = []
    @Published var teams: [Team] = []
    @Published var teamInvitations: [TeamInvitation] = []
    @Published var teamMembers: [TeamMember] = []
    
    private let tasksKey = "SavedTasks"
    private let projectsKey = "SavedProjects"
    private let teamsKey = "SavedTeams"
    private let teamInvitationsKey = "SavedTeamInvitations"
    
    private init() {
        // 清空所有现有数据，只保留eero项目的两个任务
        clearAllData()
        loadCustomCategories()  // 加载自定义类别
        loadTeamMembers()       // 加载团队成员
        createSampleData()
        loadTeamData()          // 加载团队数据
    }
    
    // MARK: - Task Management
    
    func addTask(_ task: Task) {
        allTasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
            allTasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        allTasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func updateTaskActualHours(_ task: Task, actualHours: Double) {
        let updatedTask = Task(
            id: task.id,
            title: task.title,
            description: task.description,
            startTime: task.startTime,
            endTime: task.endTime,
            dueDate: task.dueDate,
            completedAt: task.completedAt,
            isCompleted: task.isCompleted,
            priority: task.priority,
            category: task.category,
            customCategoryId: task.customCategoryId,
            createdAt: task.createdAt,
            updatedAt: Date(),
            projectId: task.projectId,
            assigneeId: task.assigneeId,
            estimatedHours: task.estimatedHours,
            actualHours: actualHours
        )
        updateTask(updatedTask)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        let newCompletionState = !task.isCompleted
        let completedAt = newCompletionState ? Date() : nil
        
        // Calculate actual hours for meeting tasks when completed
        var actualHours = task.actualHours
        if newCompletionState && task.category == .meeting && task.startTime != nil && task.endTime != nil {
            let timeInterval = task.endTime!.timeIntervalSince(task.startTime!)
            actualHours = timeInterval / 3600.0 // Convert seconds to hours
        }
        
        updatedTask = Task(
            id: task.id,
            title: task.title,
            description: task.description,
            startTime: task.startTime,
            endTime: task.endTime,
            dueDate: task.dueDate,
            completedAt: completedAt,
            isCompleted: newCompletionState,
            priority: task.priority,
            category: task.category,
            customCategoryId: task.customCategoryId,
            createdAt: task.createdAt,
            updatedAt: Date(),
            projectId: task.projectId,
            assigneeId: task.assigneeId,
            estimatedHours: task.estimatedHours,
            actualHours: actualHours
        )
        updateTask(updatedTask)
    }
    
    // MARK: - Project Management
    
    func addProject(_ project: Project) {
        allProjects.append(project)
        saveProjects()
    }
    
    func updateProject(_ project: Project) {
        if let index = allProjects.firstIndex(where: { $0.id == project.id }) {
            allProjects[index] = project
            saveProjects()
        }
    }
    
    func getProject(byId id: UUID) -> Project? {
        return allProjects.first { $0.id == id }
    }
    
    func getProject(byName name: String) -> Project? {
        return allProjects.first { $0.name == name }
    }
    
    /// 获取团队的项目
    func getTeamProjects(teamId: UUID) -> [Project] {
        return allProjects.filter { $0.ownerId == teamId }
    }
    
    /// 获取个人项目（非团队项目）
    func getPersonalProjects() -> [Project] {
        let teamIds = Set(teams.map { $0.id })
        return allProjects.filter { !teamIds.contains($0.ownerId) }
    }
    
    /// 根据项目ID获取所属团队
    func getTeamByProjectId(_ projectId: UUID) -> Team? {
        guard let project = getProject(byId: projectId) else { return nil }
        return teams.first { $0.id == project.ownerId }
    }
    

    
    /// 获取团队的所有任务
    func getTeamTasks(teamId: UUID) -> [Task] {
        let teamProjectIds = getTeamProjects(teamId: teamId).map { $0.id }
        return allTasks.filter { task in
            guard let projectId = task.projectId else { return false }
            return teamProjectIds.contains(projectId)
        }.sorted { task1, task2 in
            // 按截止日期排序，没有截止日期的排在后面
            guard let due1 = task1.dueDate else { return false }
            guard let due2 = task2.dueDate else { return true }
            return due1 < due2
        }
    }
    
    // MARK: - Data Filtering
    
    func tasksForProject(_ projectId: UUID) -> [Task] {
        return allTasks.filter { $0.projectId == projectId }
    }
    
    func pendingTasks() -> [Task] {
        return allTasks.filter { !$0.isCompleted }
    }
    
    func completedTasks() -> [Task] {
        return allTasks.filter { $0.isCompleted }
    }
    
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return allTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
    }
    
    // MARK: - Time Statistics
    
    /// 获取项目的时间统计
    func getProjectTimeStats(projectId: UUID) -> ProjectTimeStats {
        let projectTasks = tasksForProject(projectId)
        let estimatedHours = projectTasks.compactMap { $0.estimatedHours }.reduce(0, +)
        let actualHours = projectTasks.compactMap { $0.actualHours }.reduce(0, +)
        
        return ProjectTimeStats(
            projectId: projectId,
            totalEstimatedHours: estimatedHours,
            totalActualHours: actualHours,
            completedTasks: projectTasks.filter { $0.isCompleted }.count,
            totalTasks: projectTasks.count
        )
    }
    
    /// 获取每日时间统计
    func getDailyTimeStats(for date: Date) -> DailyTimeStats {
        let calendar = Calendar.current
        let dayTasks = allTasks.filter { task in
            if let completedAt = task.completedAt {
                return calendar.isDate(completedAt, inSameDayAs: date)
            }
            return false
        }
        
        let totalHours = dayTasks.compactMap { $0.actualHours }.reduce(0, +)
        let tasksByProject = Dictionary(grouping: dayTasks) { $0.projectId }
        
        var projectStats: [ProjectTimeStats] = []
        for (projectId, tasks) in tasksByProject {
            if let projectId = projectId {
                let estimatedHours = tasks.compactMap { $0.estimatedHours }.reduce(0, +)
                let actualHours = tasks.compactMap { $0.actualHours }.reduce(0, +)
                projectStats.append(ProjectTimeStats(
                    projectId: projectId,
                    totalEstimatedHours: estimatedHours,
                    totalActualHours: actualHours,
                    completedTasks: tasks.count,
                    totalTasks: tasks.count
                ))
            }
        }
        
        return DailyTimeStats(
            date: date,
            totalHours: totalHours,
            completedTasks: dayTasks.count,
            projectStats: projectStats
        )
    }
    
    /// 获取每周时间统计
    func getWeeklyTimeStats(for date: Date) -> WeeklyTimeStats {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return WeeklyTimeStats(weekStart: date, weekEnd: date, totalHours: 0, dailyStats: [], projectStats: [])
        }
        
        let weekTasks = allTasks.filter { task in
            if let completedAt = task.completedAt {
                return weekInterval.contains(completedAt)
            }
            return false
        }
        
        let totalHours = weekTasks.compactMap { $0.actualHours }.reduce(0, +)
        
        // 按日期分组
        var dailyStats: [DailyTimeStats] = []
        var currentDate = weekInterval.start
        while currentDate < weekInterval.end {
            dailyStats.append(getDailyTimeStats(for: currentDate))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // 按项目分组
        let tasksByProject = Dictionary(grouping: weekTasks) { $0.projectId }
        var projectStats: [ProjectTimeStats] = []
        for (projectId, tasks) in tasksByProject {
            if let projectId = projectId {
                let estimatedHours = tasks.compactMap { $0.estimatedHours }.reduce(0, +)
                let actualHours = tasks.compactMap { $0.actualHours }.reduce(0, +)
                projectStats.append(ProjectTimeStats(
                    projectId: projectId,
                    totalEstimatedHours: estimatedHours,
                    totalActualHours: actualHours,
                    completedTasks: tasks.count,
                    totalTasks: tasks.count
                ))
            }
        }
        
        return WeeklyTimeStats(
            weekStart: weekInterval.start,
            weekEnd: weekInterval.end,
            totalHours: totalHours,
            dailyStats: dailyStats,
            projectStats: projectStats
        )
    }
    
    /// 获取每月时间统计
    func getMonthlyTimeStats(for date: Date) -> MonthlyTimeStats {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return MonthlyTimeStats(monthStart: date, monthEnd: date, totalHours: 0, weeklyStats: [], projectStats: [])
        }
        
        let monthTasks = allTasks.filter { task in
            if let completedAt = task.completedAt {
                return monthInterval.contains(completedAt)
            }
            return false
        }
        
        let totalHours = monthTasks.compactMap { $0.actualHours }.reduce(0, +)
        
        // 按周分组
        var weeklyStats: [WeeklyTimeStats] = []
        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            weeklyStats.append(getWeeklyTimeStats(for: currentDate))
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
        }
        
        // 按项目分组
        let tasksByProject = Dictionary(grouping: monthTasks) { $0.projectId }
        var projectStats: [ProjectTimeStats] = []
        for (projectId, tasks) in tasksByProject {
            if let projectId = projectId {
                let estimatedHours = tasks.compactMap { $0.estimatedHours }.reduce(0, +)
                let actualHours = tasks.compactMap { $0.actualHours }.reduce(0, +)
                projectStats.append(ProjectTimeStats(
                    projectId: projectId,
                    totalEstimatedHours: estimatedHours,
                    totalActualHours: actualHours,
                    completedTasks: tasks.count,
                    totalTasks: tasks.count
                ))
            }
        }
        
        return MonthlyTimeStats(
            monthStart: monthInterval.start,
            monthEnd: monthInterval.end,
            totalHours: totalHours,
            weeklyStats: weeklyStats,
            projectStats: projectStats
        )
    }
    
    // MARK: - Data Management
    
    /// 清空所有保存的数据
    private func clearAllData() {
        UserDefaults.standard.removeObject(forKey: tasksKey)
        UserDefaults.standard.removeObject(forKey: projectsKey)
        allTasks.removeAll()
        allProjects.removeAll()
    }
    
    /// 重置所有数据，只保留eero项目的两个任务 (公开方法，可在需要时调用)
    func resetToEeroProjectOnly() {
        clearAllData()
        createSampleData()
    }
    
    // MARK: - 用户管理
    
    private let teamMembersKey = "team_members"
    
    /// 获取所有可用的用户列表
    func getAllUsers() -> [TeamMember] {
        return teamMembers
    }
    
    /// 添加团队成员
    func addTeamMember(_ member: TeamMember) {
        teamMembers.append(member)
        saveTeamMembers()
    }
    
    /// 更新团队成员
    func updateTeamMember(_ member: TeamMember) {
        if let index = teamMembers.firstIndex(where: { $0.id == member.id }) {
            teamMembers[index] = member
            saveTeamMembers()
        }
    }
    
    /// 删除团队成员
    func deleteTeamMember(_ memberId: UUID) {
        teamMembers.removeAll { $0.id == memberId }
        saveTeamMembers()
    }
    
    /// 获取团队成员
    func getTeamMember(byId id: UUID) -> TeamMember? {
        return teamMembers.first { $0.id == id }
    }
    
    /// 保存团队成员到UserDefaults
    private func saveTeamMembers() {
        if let encoded = try? JSONEncoder().encode(teamMembers) {
            UserDefaults.standard.set(encoded, forKey: teamMembersKey)
        }
    }
    
    /// 从UserDefaults加载团队成员
    private func loadTeamMembers() {
        if let data = UserDefaults.standard.data(forKey: teamMembersKey),
           let members = try? JSONDecoder().decode([TeamMember].self, from: data) {
            teamMembers = members
        } else {
            // 如果没有保存的数据，创建默认团队成员
            createDefaultTeamMembers()
        }
    }
    
    /// 创建默认团队成员
    private func createDefaultTeamMembers() {
        teamMembers = [
            TeamMember(
                id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
                name: "Jim",
                avatar: "person.circle.fill",
                role: "项目经理",
                isOnline: true
            ),
            TeamMember(
                id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
                name: "Clare",
                avatar: "person.circle.fill", 
                role: "开发工程师",
                isOnline: true
            )
        ]
        saveTeamMembers()
    }
    
    // MARK: - 自定义类别管理
    
    @Published var customCategories: [CustomTaskCategory] = []
    private let customCategoriesKey = "custom_categories"
    
    /// 获取所有可用的类别（默认类别 + 自定义类别）
    func getAllCategories() -> [(category: TaskCategory, custom: CustomTaskCategory?)] {
        var result: [(category: TaskCategory, custom: CustomTaskCategory?)] = []
        
        // 添加默认类别
        for category in TaskCategory.defaultCategories {
            result.append((category: category, custom: nil))
        }
        
        // 添加自定义类别
        for customCategory in customCategories {
            result.append((category: .custom, custom: customCategory))
        }
        
        return result
    }
    
    /// 添加自定义类别
    func addCustomCategory(_ category: CustomTaskCategory) {
        customCategories.append(category)
        saveCustomCategories()
    }
    
    /// 更新自定义类别
    func updateCustomCategory(_ category: CustomTaskCategory) {
        if let index = customCategories.firstIndex(where: { $0.id == category.id }) {
            customCategories[index] = category
            saveCustomCategories()
        }
    }
    
    /// 删除自定义类别
    func deleteCustomCategory(_ categoryId: UUID) {
        customCategories.removeAll { $0.id == categoryId }
        saveCustomCategories()
    }
    
    /// 获取自定义类别
    func getCustomCategory(byId id: UUID) -> CustomTaskCategory? {
        return customCategories.first { $0.id == id }
    }
    
    /// 保存自定义类别到UserDefaults
    private func saveCustomCategories() {
        if let encoded = try? JSONEncoder().encode(customCategories) {
            UserDefaults.standard.set(encoded, forKey: customCategoriesKey)
        }
    }
    
    /// 从UserDefaults加载自定义类别
    private func loadCustomCategories() {
        if let data = UserDefaults.standard.data(forKey: customCategoriesKey),
           let categories = try? JSONDecoder().decode([CustomTaskCategory].self, from: data) {
            customCategories = categories
        }
    }
    
    // MARK: - Persistence
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(allTasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let tasks = try? JSONDecoder().decode([Task].self, from: data) {
            allTasks = tasks
        }
    }
    
    private func saveProjects() {
        if let encoded = try? JSONEncoder().encode(allProjects) {
            UserDefaults.standard.set(encoded, forKey: projectsKey)
        }
    }
    
    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: projectsKey),
           let projects = try? JSONDecoder().decode([Project].self, from: data) {
            allProjects = projects
        }
    }
    
    // MARK: - Sample Data Creation
    
    private func createSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        // 创建固定的UUID用于团队成员识别
        let jimId = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        let clareId = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!
        
        // 只保留eero项目
        let eeroProject = Project(
            name: "eero",
            description: "eero项目开发",
            startDate: calendar.date(byAdding: .month, value: -1, to: today)!,
            endDate: calendar.date(byAdding: .month, value: 1, to: today)!,
            status: .active,
            ownerId: UUID(),
            color: "#10B981",
            totalTasks: 2,
            activeTasks: 2,
            completedTasks: 0,
            teamMembers: [
                TeamMember(id: jimId, name: "Jim", avatar: "person.circle.fill", isOnline: true),
                TeamMember(id: clareId, name: "Clare", avatar: "person.circle.fill", isOnline: false)
            ],
            timeLogged: 0
        )
        
        allProjects = [eeroProject]
        saveProjects()
        
        // 只保留eero项目的两个任务
        let sampleTasks = [
            // id: 1 - meeting任务，有时间段，负责人Jim，创建时间较早
            Task(
                title: "eero项目周会",
                description: "讨论eero项目本周进展和下周计划",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!,
                endTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: today)!,
                priority: .medium,
                category: .meeting,
                customCategoryId: nil,  // 使用默认类别，无需自定义类别ID
                createdAt: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: -1, to: today)!)!,
                projectId: eeroProject.id,
                assigneeId: jimId,
                estimatedHours: nil  // 会议任务通常不需要预估工时
            ),
            // id: 2 - email send任务，只有截止时间，负责人Clare，创建时间较晚
            Task(
                title: "发送项目进度邮件",
                description: "向客户发送eero项目本周进度报告",
                dueDate: calendar.date(byAdding: .day, value: 4, to: today)!, // 2025-08-08相当于today+4天
                priority: .medium,
                category: .communication,
                customCategoryId: nil,  // 使用默认类别，无需自定义类别ID
                createdAt: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: -1, to: today)!)!,
                projectId: eeroProject.id,
                assigneeId: clareId,
                estimatedHours: 2.0  // 截止任务需要预估工时
            )
        ]
        
        allTasks = sampleTasks
        saveTasks()
    }
    
    // MARK: - Team Data Management
    
    func loadTeamData() {
        loadTeams()
        loadInvitations()
    }
    
    // MARK: - Team Management
    func addTeam(_ team: Team) {
        teams.append(team)
        saveTeams()
    }
    
    func updateTeam(_ team: Team) {
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            teams[index] = team
            saveTeams()
        }
    }
    
    func deleteTeam(_ teamId: UUID) {
        teams.removeAll { $0.id == teamId }
        saveTeams()
    }
    
    // MARK: - Invitation Management
    func addInvitation(_ invitation: TeamInvitation) {
        teamInvitations.append(invitation)
        saveInvitations()
    }
    
    func acceptInvitation(_ invitationId: UUID) {
        if let invitation = teamInvitations.first(where: { $0.id == invitationId }) {
            // Create a new team based on invitation
            let newTeam = Team(
                name: invitation.teamName,
                description: invitation.teamDescription,
                members: [teamMembers.first ?? TeamMember(name: "Me")],
                totalTasks: Int.random(in: 5...25),
                activeTasks: Int.random(in: 2...8),
                completedTasks: Int.random(in: 3...15),
                recentActivity: generateSampleActivity()
            )
            addTeam(newTeam)
        }
        removeInvitation(invitationId)
    }
    
    func declineInvitation(_ invitationId: UUID) {
        removeInvitation(invitationId)
    }
    
    private func removeInvitation(_ invitationId: UUID) {
        teamInvitations.removeAll { $0.id == invitationId }
        saveInvitations()
    }
    
    // MARK: - Team Data Persistence
    private func saveTeams() {
        if let encoded = try? JSONEncoder().encode(teams) {
            UserDefaults.standard.set(encoded, forKey: teamsKey)
        }
    }
    
    private func loadTeams() {
        if let data = UserDefaults.standard.data(forKey: teamsKey),
           let savedTeams = try? JSONDecoder().decode([Team].self, from: data) {
            teams = savedTeams
        } else {
            createSampleTeams()
        }
    }
    
    private func saveInvitations() {
        if let encoded = try? JSONEncoder().encode(teamInvitations) {
            UserDefaults.standard.set(encoded, forKey: teamInvitationsKey)
        }
    }
    
    private func loadInvitations() {
        if let data = UserDefaults.standard.data(forKey: teamInvitationsKey),
           let savedInvitations = try? JSONDecoder().decode([TeamInvitation].self, from: data) {
            teamInvitations = savedInvitations
        } else {
            createSampleInvitations()
        }
    }
    
    // MARK: - Team Sample Data
    private func createSampleTeams() {
        teams = [
            Team(
                name: "Work Team",
                description: "Main development team for product features and sprint planning. Daily standups and weekly retrospectives.",
                icon: "💼",
                color: "#3B82F6",
                members: Array(teamMembers.prefix(5)),
                totalTasks: 23,
                activeTasks: 8,
                completedTasks: 15,
                recentActivity: [
                    TeamActivity(icon: "✅", description: "Sarah completed \"API Integration\"", timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!),
                    TeamActivity(icon: "📅", description: "Team meeting scheduled for tomorrow", timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!),
                    TeamActivity(icon: "🔄", description: "Mike started \"Database Migration\"", timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!)
                ]
            ),
            Team(
                name: "CS Study Group",
                description: "Computer Science study group for exam preparation and assignment collaboration. Weekly study sessions.",
                icon: "📚",
                color: "#10B981",
                members: Array(teamMembers.prefix(3)),
                totalTasks: 12,
                activeTasks: 5,
                completedTasks: 7,
                recentActivity: [
                    TeamActivity(icon: "📖", description: "Lisa shared \"Chapter 5 Notes\"", timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!),
                    TeamActivity(icon: "📅", description: "Study session scheduled for Friday", timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
                ]
            ),
            Team(
                name: "Dance Crew",
                description: "Weekly dance practice sessions and performance preparation. Fun and energetic group activities.",
                icon: "💃",
                color: "#F59E0B",
                members: teamMembers,
                totalTasks: 8,
                activeTasks: 3,
                completedTasks: 5,
                recentActivity: [
                    TeamActivity(icon: "🎵", description: "New choreography shared by Anna", timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!),
                    TeamActivity(icon: "📅", description: "Practice session tomorrow 7 PM", timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!)
                ]
            )
        ]
        saveTeams()
    }
    
    private func createSampleInvitations() {
        teamInvitations = [
            TeamInvitation(
                teamName: "Design Team",
                inviterName: "Sarah Chen",
                teamDescription: "Join our creative design team to collaborate on UI/UX projects and share design resources.",
                invitedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
            ),
            TeamInvitation(
                teamName: "Study Group",
                inviterName: "Mike Johnson",
                teamDescription: "Join our computer science study group for exam preparation and project collaboration.",
                invitedAt: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
            )
        ]
        saveInvitations()
    }
    
    private func generateSampleActivity() -> [TeamActivity] {
        return [
            TeamActivity(icon: "✅", description: "Task completed", timestamp: Date()),
            TeamActivity(icon: "📅", description: "Meeting scheduled", timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!)
        ]
    }
}

// MARK: - Task Extensions for Mutable Operations

extension Task {
    func updating(
        title: String? = nil,
        description: String? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        dueDate: Date? = nil,
        isCompleted: Bool? = nil,
        priority: TaskPriority? = nil,
        category: TaskCategory? = nil,
        customCategoryId: UUID? = nil,
        projectId: UUID? = nil,
        assigneeId: UUID? = nil,
        estimatedHours: Double? = nil,
        actualHours: Double? = nil,
        // 新增参数，用于明确是否要清除时间字段
        clearStartTime: Bool = false,
        clearEndTime: Bool = false,
        clearAssignee: Bool = false,
        clearCustomCategory: Bool = false
    ) -> Task {
        return Task(
            id: self.id,
            title: title ?? self.title,
            description: description ?? self.description,
            startTime: clearStartTime ? nil : (startTime ?? self.startTime),
            endTime: clearEndTime ? nil : (endTime ?? self.endTime),
            dueDate: dueDate ?? self.dueDate,
            completedAt: isCompleted == true ? (self.completedAt ?? Date()) : (isCompleted == false ? nil : self.completedAt),
            isCompleted: isCompleted ?? self.isCompleted,
            priority: priority ?? self.priority,
            category: category ?? self.category,
            customCategoryId: clearCustomCategory ? nil : (customCategoryId ?? self.customCategoryId),
            createdAt: self.createdAt,
            updatedAt: Date(),
            projectId: projectId ?? self.projectId,
            assigneeId: clearAssignee ? nil : (assigneeId ?? self.assigneeId),
            estimatedHours: estimatedHours ?? self.estimatedHours,
            actualHours: actualHours ?? self.actualHours
        )
    }
}
