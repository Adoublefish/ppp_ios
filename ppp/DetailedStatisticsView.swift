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
                        
                        // Time Distribution Chart
                        timeDistributionSection
                        
                        // Projects Time Investment
                        projectsTimeSection
                        
                        // Tasks Breakdown by Project
                        tasksBreakdownSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color.neuBackground)
            }
            .background(Color.neuBackground)
            .navigationTitle("详细统计")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.neuTextSecondary)
                }
            }
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
    
    // MARK: - Time Distribution Chart
    private var timeDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("时间分布")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.neuTextPrimary)
            
            VStack(spacing: 16) {
                // Simple bar chart representation
                let distributionData = getTimeDistributionData()
                
                if distributionData.isEmpty {
                    emptyChartPlaceholder
                } else {
                    ForEach(distributionData, id: \.date) { data in
                        HStack(spacing: 12) {
                            Text(formatChartDate(data.date))
                                .font(.caption)
                                .foregroundColor(.neuTextSecondary)
                                .frame(width: 50, alignment: .leading)
                            
                            GeometryReader { geometry in
                                HStack(spacing: 0) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.neuAccent, Color.neuAccent.opacity(0.7)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * CGFloat(data.hours / getMaxHours()))
                                        .frame(height: 24)
                                }
                            }
                            .frame(height: 24)
                            
                            Text(String(format: "%.1fh", data.hours))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.neuTextPrimary)
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                }
            }
            .padding(16)
            .neumorphicCard(cornerRadius: 16, padding: 0)
        }
    }
    
    // MARK: - Projects Time Section
    private var projectsTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("项目投入时间")
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
    
    // MARK: - Tasks Breakdown Section
    private var tasksBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("任务明细")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.neuTextPrimary)
            
            let tasksData = getTasksBreakdownData()
            
            if tasksData.isEmpty {
                emptyTasksPlaceholder
            } else {
                VStack(spacing: 8) {
                    ForEach(tasksData, id: \.task.id) { data in
                        TaskBreakdownRow(
                            task: data.task,
                            project: data.project,
                            hours: data.hours
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Empty States
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 32))
                .foregroundColor(.neuTextSecondary)
            
            Text("暂无数据")
                .font(.subheadline)
                .foregroundColor(.neuTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
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
    
    private var emptyTasksPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 32))
                .foregroundColor(.neuTextSecondary)
            
            Text("该时间段内无任务数据")
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
    
    private func getTimeDistributionData() -> [TimeDistributionData] {
        let calendar = Calendar.current
        var data: [TimeDistributionData] = []
        
        switch selectedTimeRange {
        case .day:
            // Show hourly distribution for the day
            for hour in 0..<24 {
                var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                components.hour = hour
                components.minute = 0
                components.second = 0
                
                if let hourDate = calendar.date(from: components) {
                    let tasks = getFilteredTasks().filter { task in
                        guard let startTime = task.startTime else { return false }
                        return calendar.component(.hour, from: startTime) == hour
                    }
                    let hours = tasks.reduce(0.0) { $0 + ($1.actualHours ?? 0) }
                    if hours > 0 {
                        data.append(TimeDistributionData(date: hourDate, hours: hours))
                    }
                }
            }
            
        case .week:
            // Show daily distribution for the week
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
                return []
            }
            
            var currentDate = weekInterval.start
            for _ in 0..<7 {
                let tasks = dataManager.allTasks.filter { task in
                    let createdAt = task.createdAt
                    return calendar.isDate(createdAt, inSameDayAs: currentDate)
                }
                let hours = tasks.reduce(0.0) { $0 + ($1.actualHours ?? 0) }
                data.append(TimeDistributionData(date: currentDate, hours: hours))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            
        case .month:
            // Show weekly distribution for the month
            guard let range = calendar.range(of: .weekOfMonth, in: .month, for: selectedDate) else {
                return []
            }
            
            for week in range {
                var components = calendar.dateComponents([.year, .month], from: selectedDate)
                components.weekOfMonth = week
                
                if let weekDate = calendar.date(from: components) {
                    let tasks = dataManager.allTasks.filter { task in
                        let createdAt = task.createdAt
                        return calendar.isDate(createdAt, equalTo: weekDate, toGranularity: .weekOfMonth)
                    }
                    let hours = tasks.reduce(0.0) { $0 + ($1.actualHours ?? 0) }
                    data.append(TimeDistributionData(date: weekDate, hours: hours))
                }
            }
        }
        
        return data
    }
    
    private func getMaxHours() -> Double {
        let data = getTimeDistributionData()
        return data.map { $0.hours }.max() ?? 1.0
    }
    
    private func formatChartDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        switch selectedTimeRange {
        case .day:
            formatter.dateFormat = "HH:mm"
        case .week:
            formatter.dateFormat = "E"
        case .month:
            formatter.dateFormat = "第W周"
        }
        
        return formatter.string(from: date)
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
    
    private func getTasksBreakdownData() -> [TaskBreakdownData] {
        let tasks = getFilteredTasks()
            .filter { ($0.actualHours ?? 0) > 0 }
            .sorted { ($0.actualHours ?? 0) > ($1.actualHours ?? 0) }
        
        return tasks.map { task in
            let project = task.projectId.flatMap { dataManager.getProject(byId: $0) }
            return TaskBreakdownData(task: task, project: project, hours: task.actualHours ?? 0)
        }
    }
}

// MARK: - Data Models
struct TimeDistributionData {
    let date: Date
    let hours: Double
}

struct ProjectTimeData {
    let project: Project
    let hours: Double
    let taskCount: Int
}

struct TaskBreakdownData {
    let task: Task
    let project: Project?
    let hours: Double
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

// MARK: - Task Breakdown Row Component
struct TaskBreakdownRow: View {
    let task: Task
    let project: Project?
    let hours: Double
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(priorityColor)
                .frame(width: 4, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.neuTextPrimary)
                    .lineLimit(1)
                
                if let project = project {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: project.color))
                            .frame(width: 8, height: 8)
                        
                        Text(project.name)
                            .font(.caption)
                            .foregroundColor(.neuTextSecondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1fh", hours))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.neuAccent)
                
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(12)
        .background(Color.neuBackground)
        .cornerRadius(12)
        .neumorphicCard(cornerRadius: 12, padding: 0)
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .urgent:
            return .red
        case .high:
            return .orange
        case .medium:
            return .neuAccent
        case .low:
            return .green
        }
    }
}

#Preview {
    DetailedStatisticsView()
}

