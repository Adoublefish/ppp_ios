//
//  UserDataManager.swift
//  ppp
//
//  Created by Kiro on 9/22/25.
//

import Foundation
import SwiftUI

class UserDataManager: ObservableObject {
    static let shared = UserDataManager()
    
    // 用户基本信息
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
            updateUserInitials()
        }
    }
    
    @Published var userEmail: String {
        didSet {
            UserDefaults.standard.set(userEmail, forKey: "userEmail")
        }
    }
    
    @Published var userInitials: String {
        didSet {
            UserDefaults.standard.set(userInitials, forKey: "userInitials")
        }
    }
    
    // 用户设置
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var calendarSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(calendarSyncEnabled, forKey: "calendarSyncEnabled")
        }
    }
    
    @Published var aiFeatureEnabled: Bool {
        didSet {
            UserDefaults.standard.set(aiFeatureEnabled, forKey: "aiFeatureEnabled")
        }
    }
    
    @Published var darkModePreference: DarkModePreference {
        didSet {
            UserDefaults.standard.set(darkModePreference.rawValue, forKey: "darkModePreference")
        }
    }
    
    @Published var selectedLanguage: Language {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        }
    }
    
    @Published var cloudBackupEnabled: Bool {
        didSet {
            UserDefaults.standard.set(cloudBackupEnabled, forKey: "cloudBackupEnabled")
        }
    }
    
    private init() {
        // 从UserDefaults加载数据
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? "用户"
        self.userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "user@example.com"
        self.userInitials = UserDefaults.standard.string(forKey: "userInitials") ?? "用"
        
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        self.calendarSyncEnabled = UserDefaults.standard.object(forKey: "calendarSyncEnabled") as? Bool ?? true
        self.aiFeatureEnabled = UserDefaults.standard.object(forKey: "aiFeatureEnabled") as? Bool ?? true
        self.cloudBackupEnabled = UserDefaults.standard.object(forKey: "cloudBackupEnabled") as? Bool ?? true
        
        let darkModeString = UserDefaults.standard.string(forKey: "darkModePreference") ?? DarkModePreference.automatic.rawValue
        self.darkModePreference = DarkModePreference(rawValue: darkModeString) ?? .automatic
        
        let languageString = UserDefaults.standard.string(forKey: "selectedLanguage") ?? Language.chinese.rawValue
        self.selectedLanguage = Language(rawValue: languageString) ?? .chinese
        
        // 如果是首次启动，生成初始头像字母
        if UserDefaults.standard.object(forKey: "userInitials") == nil {
            updateUserInitials()
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateUserInitials() {
        userInitials = generateInitials(from: userName)
    }
    
    private func generateInitials(from name: String) -> String {
        let components = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        if components.isEmpty {
            return "用"
        } else if components.count == 1 {
            let firstChar = String(components[0].prefix(1))
            if firstChar.range(of: "\\p{Han}", options: .regularExpression) != nil {
                // 中文名字，取第一个字
                return firstChar
            } else {
                // 英文名字，取前两个字母
                return String(components[0].prefix(2)).uppercased()
            }
        } else {
            let firstInitial = String(components[0].prefix(1))
            let lastInitial = String(components[1].prefix(1))
            
            // 检查是否包含中文
            if firstInitial.range(of: "\\p{Han}", options: .regularExpression) != nil ||
               lastInitial.range(of: "\\p{Han}", options: .regularExpression) != nil {
                // 中文名字，取姓和名的第一个字
                return firstInitial + lastInitial
            } else {
                // 英文名字，取首字母并大写
                return (firstInitial + lastInitial).uppercased()
            }
        }
    }
    
    // MARK: - User Actions
    
    func updateProfile(name: String, email: String) {
        userName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        userEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func resetToDefaults() {
        userName = "用户"
        userEmail = "user@example.com"
        notificationsEnabled = true
        calendarSyncEnabled = true
        aiFeatureEnabled = true
        darkModePreference = .automatic
        selectedLanguage = .chinese
        cloudBackupEnabled = true
    }
    
    func signOut() {
        // 清除用户数据但保留设置
        userName = "用户"
        userEmail = "user@example.com"
        
        // 可以选择是否清除设置
        // resetToDefaults()
    }
    
    // MARK: - Statistics
    
    func getUserStatistics() -> UserStatistics {
        let taskManager = TaskDataManager.shared
        
        let totalTasks = taskManager.allTasks.count
        let completedTasks = taskManager.allTasks.filter { $0.isCompleted }.count
        let totalProjects = taskManager.allProjects.count
        let totalHours = calculateTotalHours()
        
        return UserStatistics(
            totalTasks: totalTasks,
            completedTasks: completedTasks,
            totalProjects: totalProjects,
            totalHours: totalHours
        )
    }
    
    private func calculateTotalHours() -> Int {
        let taskManager = TaskDataManager.shared
        var totalMinutes = 0
        
        // 计算已完成任务的时间
        for task in taskManager.allTasks.filter({ $0.isCompleted }) {
            if let startTime = task.startTime, let endTime = task.endTime {
                let minutes = Calendar.current.dateComponents([.minute], from: startTime, to: endTime).minute ?? 0
                totalMinutes += minutes
            } else {
                // 对于没有具体时间的任务，估算2小时
                totalMinutes += 120
            }
        }
        
        return totalMinutes / 60
    }
}

// MARK: - Supporting Types

struct UserStatistics {
    let totalTasks: Int
    let completedTasks: Int
    let totalProjects: Int
    let totalHours: Int
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0.0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var averageHoursPerTask: Double {
        guard completedTasks > 0 else { return 0.0 }
        return Double(totalHours) / Double(completedTasks)
    }
}