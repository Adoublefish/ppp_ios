//
//  DetailedStatisticsView.swift
//  ppp
//
//  Created on 2025-10-13.
//

import SwiftUI
import Charts

struct DetailedStatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedDate = Date()
    
    enum TimeRange: String, CaseIterable {
        case day = "日"
        case week = "周"
        case month = "月"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Time Range Selector
                timeRangeSelectorView
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.neuBackground)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Overview Statistics Cards
                        overviewStatsSection
                        
                        // Projects Time Investment (时间线)
                        projectsTimeSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color.neuBackground)
            }
            .background(Color.neuBackground)
            .navigationTitle("详细统计")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Time Range Selector
    private var timeRangeSelectorView: some View {
        VStack(spacing: 12) {
            // Time range pills
            HStack(spacing: 8) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    NeumorphicPillButton(
                        title: range.rawValue,
                        color: .neuAccent,
                        isSelected: selectedTimeRange == range
                    ) {
                        selectedTimeRange = range
                    }
                }
            }
            
            // Date navigation
            HStack {
                NeumorphicIconButton(
                    icon: "chevron.left",
                    size: 36,
                    iconSize: 14,
                    color: .neuBackground,
                    iconColor: .neuAccent,
                    action: {
                        navigateDate(forward: false)
                    }
                )
                
                Spacer()
                
                Text(getDateRangeString())
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.neuTextPrimary)
                
                Spacer()
                
                NeumorphicIconButton(
                    icon: "chevron.right",
                    size: 36,
                    iconSize: 14,
                    color: .neuBackground,
                    iconColor: .neuAccent,
                    action: {
                        navigateDate(forward: true)
                    }
                )
            }
        }
    }
    
    // MARK: - Overview Stats Section
    private var overviewStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("总览")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.neuTextPrimary)
            
            HStack(spacing: 12) {
                StatCard(
                    title: "总时长",
                    value: String(format: "%.1f", getTotalHours()),
                    unit: "小时",
                    icon: "clock.fill",
                    color: .neuAccent
                )
                
                StatCard(
                    title: "任务数",
                    value: getCompletedTasks(),
                    unit: "个",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "项目数",
                    value: getActiveProjects(),
                    unit: "个",
                    icon: "folder.fill",
                    color: .orange
                )
            }
        }
    }
    

    
    // MARK: - Projects Time Section
    private var projectsTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("时间线")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.neuTextPrimary)
            
            let projectsData = getProjectsTimeData()
            
            if projectsData.isEmpty {
                emptyProjectsPlaceholder
            } else {
                VStack(spacing: 12) {
                    ForEach(projectsData, id: \.project.id) { data in
                        ProjectTimeCard(
                            project: data.project,
                            hours: data.hours,
                            taskCount: data.taskCount,
                            percentage: data.hours / getTotalHours()
                        )
                    }
                }
            }
        }
    }
    

    
    // MARK: - Empty States
    private var emptyProjectsPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 32))
                .foregroundColor(.neuTextSecondary)
            
            Text("该时间段内无项目数据")
                .font(.subheadline)
                .foregroundColor(.neuTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .neumorphicInset(cornerRadius: 16)
    }
    
    // MARK: - Helper Functions
    private func navigateDate(forward: Bool) {
        let calendar = Calendar.current
        let component: Calendar.Component
        
        switch selectedTimeRange {
        case .day:
            component = .day
        case .week:
            component = .weekOfYear
        case .month:
            component = .month
        }
        
        if let newDate = calendar.date(byAdding: component, value: forward ? 1 : -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func getDateRangeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        switch selectedTimeRange {
        case .day:
            formatter.dateFormat = "M月d日 EEEE"
            return formatter.string(from: selectedDate)
            
        case .week:
            let calendar = Calendar.current
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
                return ""
            }
            formatter.dateFormat = "M月d日"
            let start = formatter.string(from: weekInterval.start)
            let end = formatter.string(from: weekInterval.end)
            return "\(start) - \(end)"
            
        case .month:
            formatter.dateFormat = "yyyy年M月"
            return formatter.string(from: selectedDate)
        }
    }
    
    private func getTotalHours() -> Double {
        let tasks = getFilteredTasks()
        return tasks.reduce(0.0) { $0 + ($1.actualHours ?? 0) }
    }
    
    private func getCompletedTasks() -> String {
        let tasks = getFilteredTasks()
        return "\(tasks.filter { $0.isCompleted }.count)"
    }
    
    private func getActiveProjects() -> String {
        let tasks = getFilteredTasks()
        let projectIds = Set(tasks.compactMap { $0.projectId })
        return "\(projectIds.count)"
    }
    
    private func getFilteredTasks() -> [Task] {
        let calendar = Calendar.current
        
        return dataManager.allTasks.filter { task in
            let createdAt = task.createdAt
            
            switch selectedTimeRange {
            case .day:
                return calendar.isDate(createdAt, inSameDayAs: selectedDate)
                
            case .week:
                guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
                    return false
                }
                return createdAt >= weekInterval.start && createdAt < weekInterval.end
                
            case .month:
                return calendar.isDate(createdAt, equalTo: selectedDate, toGranularity: .month)
            }
        }
    }
    

    
    private func getProjectsTimeData() -> [ProjectTimeData] {
        let tasks = getFilteredTasks()
        var projectTimeMap: [UUID: (project: Project, hours: Double, taskCount: Int)] = [:]
        
        for task in tasks {
            guard let projectId = task.projectId,
                  let project = dataManager.getProject(byId: projectId) else {
                continue
            }
            
            let hours = task.actualHours ?? 0
            
            if var existing = projectTimeMap[projectId] {
                existing.hours += hours
                existing.taskCount += 1
                projectTimeMap[projectId] = existing
            } else {
                projectTimeMap[projectId] = (project, hours, 1)
            }
        }
        
        return projectTimeMap.map { ProjectTimeData(project: $0.value.project, hours: $0.value.hours, taskCount: $0.value.taskCount) }
            .sorted { $0.hours > $1.hours }
    }
    

}

// MARK: - Data Models
struct ProjectTimeData {
    let project: Project
    let hours: Double
    let taskCount: Int
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.neuTextPrimary)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.neuTextSecondary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.neuTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .neumorphicCard(cornerRadius: 16, padding: 0)
    }
}

// MARK: - Project Time Card Component
struct ProjectTimeCard: View {
    let project: Project
    let hours: Double
    let taskCount: Int
    let percentage: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color(hex: project.color))
                    .frame(width: 12, height: 12)
                
                Text(project.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.neuTextPrimary)
                
                Spacer()
                
                Text(String(format: "%.1fh", hours))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.neuAccent)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.neuBackground)
                        .frame(height: 8)
                        .neumorphicInset(cornerRadius: 4)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: project.color), Color(hex: project.color).opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(min(percentage, 1.0)), height: 6)
                        .padding(.leading, 1)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(taskCount) 个任务")
                    .font(.caption)
                    .foregroundColor(.neuTextSecondary)
                
                Spacer()
                
                Text(String(format: "%.1f%%", percentage * 100))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.neuTextPrimary)
            }
        }
        .padding(16)
        .neumorphicCard(cornerRadius: 16, padding: 0)
    }
}



#Preview {
    DetailedStatisticsView()
}

