//
//  TaskModel.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import Foundation
import CoreTransferable

// MARK: - Database-compatible Task Model
struct Task: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let dueDate: Date
    let completedAt: Date?
    let isCompleted: Bool
    let priority: TaskPriority
    let category: TaskCategory
    let createdAt: Date
    let updatedAt: Date
    let projectId: UUID?
    let assigneeId: UUID?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        dueDate: Date,
        completedAt: Date? = nil,
        isCompleted: Bool = false,
        priority: TaskPriority,
        category: TaskCategory,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        projectId: UUID? = nil,
        assigneeId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.completedAt = completedAt
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.projectId = projectId
        self.assigneeId = assigneeId
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
        }
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