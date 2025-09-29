//
//  TaskModel.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import Foundation
import CoreTransferable
import SwiftUI

// MARK: - Database-compatible Task Model
struct Task: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let startTime: Date?     // 开始时间 (可选)
    let endTime: Date?       // 结束时间 (可选)
    let dueDate: Date?       // 截止日期 (可选)
    let completedAt: Date?
    let isCompleted: Bool
    let priority: TaskPriority
    let category: TaskCategory
    let customCategoryId: UUID?  // 自定义类别ID（当category为.custom时使用）
    let createdAt: Date
    let updatedAt: Date
    let projectId: UUID?
    let assigneeId: UUID?
    let estimatedHours: Double?  // 预估所需时间（小时）
    let actualHours: Double?     // 实际花费时间（小时）
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        startTime: Date? = nil,
        endTime: Date? = nil,
        dueDate: Date? = nil,
        completedAt: Date? = nil,
        isCompleted: Bool = false,
        priority: TaskPriority,
        category: TaskCategory,
        customCategoryId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        projectId: UUID? = nil,
        assigneeId: UUID? = nil,
        estimatedHours: Double? = nil,
        actualHours: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.dueDate = dueDate
        self.completedAt = completedAt
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.customCategoryId = customCategoryId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.projectId = projectId
        self.assigneeId = assigneeId
        self.estimatedHours = estimatedHours
        self.actualHours = actualHours
    }
    
    // MARK: - Computed Properties
    
    /// 是否是时间段任务 (有开始和结束时间)
    var isTimeRangeTask: Bool {
        return startTime != nil && endTime != nil
    }
    
    /// 是否是截止日期任务 (只有截止时间)
    var isDeadlineTask: Bool {
        return dueDate != nil
    }
    
    /// 任务持续时间 (如果是时间段任务)
    var duration: String? {
        guard let start = startTime, let end = endTime else { return nil }
        let minutes = Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h\(remainingMinutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(remainingMinutes)m"
        }
    }
    
    /// 格式化预估时间
    var formattedEstimatedTime: String? {
        guard let hours = estimatedHours else { return nil }
        if hours >= 1 {
            return String(format: "%.1fh", hours)
        } else {
            let minutes = Int(hours * 60)
            return "\(minutes)m"
        }
    }
    
    /// 格式化实际时间
    var formattedActualTime: String? {
        guard let hours = actualHours else { return nil }
        if hours >= 1 {
            return String(format: "%.1fh", hours)
        } else {
            let minutes = Int(hours * 60)
            return "\(minutes)m"
        }
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var weight: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .urgent: return 4
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case meeting = "meeting"
    case review = "review"
    case development = "development"
    case design = "design"
    case communication = "communication"
    case presentation = "presentation"
    case milestone = "milestone"
    case planning = "planning"
    case testing = "testing"
    case documentation = "documentation"
    case custom = "custom"  // 自定义类别标识
    
    var displayName: String {
        switch self {
        case .meeting: return "会议"
        case .review: return "审查"
        case .development: return "开发"
        case .design: return "设计"
        case .communication: return "沟通"
        case .presentation: return "汇报"
        case .milestone: return "里程碑"
        case .planning: return "规划"
        case .testing: return "测试"
        case .documentation: return "文档"
        case .custom: return "自定义"
        }
    }
    
    var iconName: String {
        switch self {
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
        case .custom: return "tag"
        }
    }
    
    var color: Color {
        switch self {
        case .meeting: return .blue
        case .review: return .green
        case .development: return .orange
        case .design: return .purple
        case .communication: return .cyan
        case .presentation: return .indigo
        case .milestone: return .red
        case .planning: return .mint
        case .testing: return .yellow
        case .documentation: return .gray
        case .custom: return .secondary
        }
    }
    
    static var defaultCategories: [TaskCategory] {
        return [.meeting, .review, .development, .design, .communication, .presentation, .milestone, .planning, .testing, .documentation]
    }
}

// MARK: - 自定义类别模型
struct CustomTaskCategory: Identifiable, Codable {
    let id: UUID
    let name: String
    let color: String  // 十六进制颜色代码
    let icon: String   // SF Symbol 名称
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        color: String = "#3B82F6",
        icon: String = "folder",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.createdAt = createdAt
    }
}

// MARK: - Database-compatible Schedule Model
struct ScheduleItem: Identifiable, Transferable, Codable {
    let id: UUID
    let title: String
    let description: String?
    let startTime: Date
    let endTime: Date
    let category: TaskCategory
    let isAllDay: Bool
    let location: String?
    let attendees: [UUID]?
    let createdAt: Date
    let updatedAt: Date
    let calendarId: UUID?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        startTime: Date,
        endTime: Date,
        category: TaskCategory,
        isAllDay: Bool = false,
        location: String? = nil,
        attendees: [UUID]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        calendarId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.isAllDay = isAllDay
        self.location = location
        self.attendees = attendees
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.calendarId = calendarId
    }
    
    var duration: String {
        let minutes = Calendar.current.dateComponents([.minute], from: startTime, to: endTime).minute ?? 0
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h\(remainingMinutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(remainingMinutes)m"
        }
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: ScheduleItem.self, contentType: .data)
    }
}

// MARK: - User Model (for reference)
struct User: Identifiable, Codable {
    let id: UUID
    let name: String
    let email: String
    let avatar: String?
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Project Model (Enhanced for Project Overview)
struct Project: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String?
    let startDate: Date
    let endDate: Date?
    let status: ProjectStatus
    let ownerId: UUID
    let createdAt: Date
    let updatedAt: Date
    
    // Additional properties for project overview
    let color: String // Hex color code
    let totalTasks: Int
    let activeTasks: Int
    let completedTasks: Int
    let teamMembers: [TeamMember]
    let timeLogged: TimeInterval // in seconds
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        startDate: Date,
        endDate: Date? = nil,
        status: ProjectStatus,
        ownerId: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        color: String = "#3B82F6",
        totalTasks: Int = 0,
        activeTasks: Int = 0,
        completedTasks: Int = 0,
        teamMembers: [TeamMember] = [],
        timeLogged: TimeInterval = 0
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.ownerId = ownerId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.color = color
        self.totalTasks = totalTasks
        self.activeTasks = activeTasks
        self.completedTasks = completedTasks
        self.teamMembers = teamMembers
        self.timeLogged = timeLogged
    }
    
    var progressPercentage: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var formattedTimeLogged: String {
        let hours = Int(timeLogged) / 3600
        return "\(hours) 小时"
    }
    
    var statusDisplayName: String {
        switch status {
        case .planning: return "规划中"
        case .active: return "进行中"
        case .onHold: return "暂停"
        case .completed: return "已完成"
        case .cancelled: return "已取消"
        }
    }
    
    var statusColor: String {
        switch status {
        case .planning: return "#6B7280"
        case .active: return "#F59E0B"
        case .onHold: return "#EF4444"
        case .completed: return "#10B981"
        case .cancelled: return "#9CA3AF"
        }
    }
    
    var isOverdue: Bool {
        guard let endDate = endDate else { return false }
        return Date() > endDate && status != .completed
    }
}

enum ProjectStatus: String, CaseIterable, Codable {
    case planning = "planning"
    case active = "active"
    case onHold = "on_hold"
    case completed = "completed"
    case cancelled = "cancelled"
}

// MARK: - Team Member Model
struct TeamMember: Identifiable, Codable {
    let id: UUID
    let name: String
    let avatar: String? // URL or system image name
    let role: String?
    let isOnline: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        avatar: String? = nil,
        role: String? = nil,
        isOnline: Bool = false
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.role = role
        self.isOnline = isOnline
    }
}

// MARK: - Project Statistics Model
struct ProjectStatistics {
    let totalProjects: Int
    let activeProjects: Int
    let completedProjects: Int
    
    var onHoldProjects: Int {
        totalProjects - activeProjects - completedProjects
    }
}

// MARK: - Team Collaboration Models
struct Team: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let color: String
    let members: [TeamMember]
    let isActive: Bool
    let totalTasks: Int
    let activeTasks: Int
    let completedTasks: Int
    let recentActivity: [TeamActivity]
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        icon: String = "person.3.fill",
        color: String = "#3B82F6",
        members: [TeamMember] = [],
        isActive: Bool = true,
        totalTasks: Int = 0,
        activeTasks: Int = 0,
        completedTasks: Int = 0,
        recentActivity: [TeamActivity] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.members = members
        self.isActive = isActive
        self.totalTasks = totalTasks
        self.activeTasks = activeTasks
        self.completedTasks = completedTasks
        self.recentActivity = recentActivity
        self.createdAt = createdAt
    }
}

struct TeamInvitation: Identifiable, Codable {
    let id: UUID
    let teamName: String
    let inviterName: String
    let teamDescription: String
    let invitedAt: Date
    
    init(
        id: UUID = UUID(),
        teamName: String,
        inviterName: String,
        teamDescription: String,
        invitedAt: Date = Date()
    ) {
        self.id = id
        self.teamName = teamName
        self.inviterName = inviterName
        self.teamDescription = teamDescription
        self.invitedAt = invitedAt
    }
}

struct TeamActivity: Identifiable, Codable {
    let id: UUID
    let icon: String
    let description: String
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        icon: String,
        description: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.icon = icon
        self.description = description
        self.timestamp = timestamp
    }
}

// MARK: - Time Statistics Models

struct ProjectTimeStats: Identifiable {
    let id = UUID()
    let projectId: UUID
    let totalEstimatedHours: Double
    let totalActualHours: Double
    let completedTasks: Int
    let totalTasks: Int
    
    var efficiency: Double {
        guard totalEstimatedHours > 0 else { return 0 }
        return totalActualHours / totalEstimatedHours
    }
    
    var formattedEstimatedTime: String {
        formatHours(totalEstimatedHours)
    }
    
    var formattedActualTime: String {
        formatHours(totalActualHours)
    }
    
    private func formatHours(_ hours: Double) -> String {
        if hours >= 1 {
            return String(format: "%.1fh", hours)
        } else {
            let minutes = Int(hours * 60)
            return "\(minutes)m"
        }
    }
}

struct DailyTimeStats: Identifiable {
    let id = UUID()
    let date: Date
    let totalHours: Double
    let completedTasks: Int
    let projectStats: [ProjectTimeStats]
    
    var formattedTotalTime: String {
        if totalHours >= 1 {
            return String(format: "%.1fh", totalHours)
        } else {
            let minutes = Int(totalHours * 60)
            return "\(minutes)m"
        }
    }
}

struct WeeklyTimeStats: Identifiable {
    let id = UUID()
    let weekStart: Date
    let weekEnd: Date
    let totalHours: Double
    let dailyStats: [DailyTimeStats]
    let projectStats: [ProjectTimeStats]
    
    var formattedTotalTime: String {
        if totalHours >= 1 {
            return String(format: "%.1fh", totalHours)
        } else {
            let minutes = Int(totalHours * 60)
            return "\(minutes)m"
        }
    }
    
    var averageDailyHours: Double {
        return totalHours / 7.0
    }
}

struct MonthlyTimeStats: Identifiable {
    let id = UUID()
    let monthStart: Date
    let monthEnd: Date
    let totalHours: Double
    let weeklyStats: [WeeklyTimeStats]
    let projectStats: [ProjectTimeStats]
    
    var formattedTotalTime: String {
        if totalHours >= 1 {
            return String(format: "%.1fh", totalHours)
        } else {
            let minutes = Int(totalHours * 60)
            return "\(minutes)m"
        }
    }
    
    var averageDailyHours: Double {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: monthStart, to: monthEnd).day ?? 30
        return totalHours / Double(days)
    }
}