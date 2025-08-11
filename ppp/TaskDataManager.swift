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
    
    private let tasksKey = "SavedTasks"
    private let projectsKey = "SavedProjects"
    
    private init() {
        // 清空所有现有数据，只保留eero项目的两个任务
        clearAllData()
        loadCustomCategories()  // 加载自定义类别
        loadTeamMembers()       // 加载团队成员
        createSampleData()
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
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask = Task(
            id: task.id,
            title: task.title,
            description: task.description,
            startTime: task.startTime,
            endTime: task.endTime,
            dueDate: task.dueDate,
            completedAt: task.isCompleted ? nil : Date(),
            isCompleted: !task.isCompleted,
            priority: task.priority,
            category: task.category,
            customCategoryId: task.customCategoryId,
            createdAt: task.createdAt,
            updatedAt: Date(),
            projectId: task.projectId,
            assigneeId: task.assigneeId
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
    
    @Published var teamMembers: [TeamMember] = []
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
                title: "meeting",
                description: "eero meeting",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!,
                endTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: today)!,
                priority: .medium,
                category: .meeting,
                customCategoryId: nil,  // 使用默认类别，无需自定义类别ID
                createdAt: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: -1, to: today)!)!,
                projectId: eeroProject.id,
                assigneeId: jimId
            ),
            // id: 2 - email send任务，只有截止时间，负责人Clare，创建时间较晚
            Task(
                title: "email send",
                description: "send email for xxx",
                dueDate: calendar.date(byAdding: .day, value: 4, to: today)!, // 2025-08-08相当于today+4天
                priority: .medium,
                category: .communication,
                customCategoryId: nil,  // 使用默认类别，无需自定义类别ID
                createdAt: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: -1, to: today)!)!,
                projectId: eeroProject.id,
                assigneeId: clareId
            )
        ]
        
        allTasks = sampleTasks
        saveTasks()
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
            assigneeId: clearAssignee ? nil : (assigneeId ?? self.assigneeId)
        )
    }
} 