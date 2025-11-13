//
//  EnhancedStatisticsView.swift
//  ppp
//
//  Created on 2025-10-17.
//

import SwiftUI
import Charts

struct EnhancedStatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedDate = Date()
    @State private var showingTimeline = false
    
    enum TimeRange: String, CaseIterable {
        case week = "周"
        case month = "月"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with controls
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.neuBackground)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Time Overview Cards
                        timeOverviewSection
                        
                        // Completed Projects Section
                        completedProjectsSection
                        
                        // Time Distribution Chart
                        timeDistributionSection
                        
                        // Timeline Section
                        timelineSection
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
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Time Range Selector
            HStack(spacing: 8) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    NeumorphicPillButton(
                        title: range.displayName,
                        color: .neuAccent,
                        isSelected: selectedTimeRange == range
                    ) {
                        selectedTimeRange = range
                    }
                }
                
                Spacer()
                
                // Timeline toggle button
                NeumorphicIconButton(
                    icon: showingTimeline ? "timeline.selection" : "clock.arrow.circlepath",
                    size: 40,
                    iconSize: 16,
                    color: showingTimeline ? .neuAccent : .neuBackground,
                    iconColor: showingTimeline ? .white : .neuAccent
                ) {
                    showingTimeline.toggle()
                }
            }
            
            // Date Navigation
            HStack {
                NeumorphicIconButton(
                    icon: "chevron.left",
                    size: 36,
                    iconSize: 14,
                    color: .neuBackground,
                    iconColor: .neuAccent
                ) {
                    navigateDate(forward: false)
                }
                
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
                    iconColor: .neuAccent
                ) {
                    navigateDate(forward: true)
                }
            }
        }
    }
    
    // MARK: - Time Overview Section
    private var timeOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("时间概览")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.neuTextPrimary)
                
                Spacer()
                
                Text(selectedTimeRange.displayName)
                    .font(.caption)
                    .foregroundColor(.neuTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.neuAccent.opacity(0.1))
                    .cornerRadius(8)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                // Total Time
                EnhancedStatCard(
                    title: "总时长",
                    value: String(format: "%.1f", getTotalHours()),
                    unit: "小时",
                    icon: "clock.fill",
                    color: .neuAccent
                )
                
                // Completed Tasks
                EnhancedStatCard(
                    title: "完成任务",
                    value: "\(getCompletedTasksCount())",
                    unit: "个",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                // Active Projects
                EnhancedStatCard(
                    title: "活跃项目",
                    value: "\(getActiveProjectsCount())",
                    unit: "个",
                    icon: "folder.fill",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Completed Projects Section
    private var completedProjectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("完成项目")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.neuTextPrimary)
                
                Spacer()
                
                Text("\(getCompletedProjects().count) 个")
                    .font(.caption)
                    .foregroundColor(.neuTextSecondary)
            }
            
            let completedProjects = getCompletedProjects()
            
            if completedProjects.isEmpty {
                emptyProjectsPlaceholder
            } else {
                VStack(spacing: 12) {
                    ForEach(completedProjects, id: \.id) { project in
                        CompletedProjectCard(
                            project: project,
                            timeSpent: getProjectTimeSpent(project.id),
                            tasksCompleted: getProjectCompletedTasks(project.id)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Time Distribution Section
    private var timeDistributionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("时间分布")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.neuTextPrimary)
            
            let distributionData = getTimeDistributionData()
            
            if distributionData.isEmpty {
                emptyChartPlaceholder
            } else {
                VStack(spacing: 12) {
                    ForEach(distributionData, id: \.date) { data in
                        TimeDistributionBar(
                            date: data.date,
                            hours: data.hours,
                            maxHours: getMaxHours(),
                            timeRange: selectedTimeRange
                        )
                    }
                }
                .padding(16)
                .neumorphicCard(cornerRadius: 16, padding: 0)
            }
        }
    }
    
    // MARK: - Timeline Section
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("时间线")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.neuTextPrimary)
                
                Spacer()
                
                Button(action: {
                    showingTimeline.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: showingTimeline ? "eye.slash" : "eye")
                            .font(.caption)
                        Text(showingTimeline ? "隐藏" : "显示")
                            .font(.caption)
                    }
                    .foregroundColor(.neuAccent)
                }
            }
            
            if showingTimeline {
                TimelineView(
                    timeRange: selectedTimeRange,
                    selectedDate: selectedDate,
                    tasks: getFilteredTasks()
                )
            }
        }
    }
    
    // MARK: - Empty States
    private var emptyProjectsPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 32))
                .foregroundColor(.neuTextSecondary)
            
            Text("该时间段内无完成项目")
                .font(.subheadline)
                .foregroundColor(.neuTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .neumorphicInset(cornerRadius: 16)
    }
    
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 32))
                .foregroundColor(.neuTextSecondary)
            
            Text("暂无时间数据")
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
        let component: Calendar.Component = selectedTimeRange == .week ? .weekOfYear : .month
        
        if let newDate = calendar.date(byAdding: component, value: forward ? 1 : -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func getDateRangeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        switch selectedTimeRange {
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
    
    private func getCompletedTasksCount() -> Int {
        return getFilteredTasks().filter { $0.isCompleted }.count
    }
    
    private func getActiveProjectsCount() -> Int {
        let tasks = getFilteredTasks()
        let projectIds = Set(tasks.compactMap { $0.projectId })
        return projectIds.count
    }
    
    private func getCompletedProjects() -> [Project] {
        let tasks = getFilteredTasks()
        let projectIds = Set(tasks.compactMap { $0.projectId })
        
        return dataManager.allProjects.filter { project in
            guard projectIds.contains(project.id) else { return false }
            
            // Check if project has completed tasks in the time range
            let projectTasks = tasks.filter { $0.projectId == project.id }
            return projectTasks.contains { $0.isCompleted }
        }
    }
    
    private func getProjectTimeSpent(_ projectId: UUID) -> Double {
        let tasks = getFilteredTasks().filter { $0.projectId == projectId }
        return tasks.reduce(0.0) { $0 + ($1.actualHours ?? 0) }
    }
    
    private func getProjectCompletedTasks(_ projectId: UUID) -> Int {
        let tasks = getFilteredTasks().filter { $0.projectId == projectId && $0.isCompleted }
        return tasks.count
    }
    
    private func getFilteredTasks() -> [Task] {
        let calendar = Calendar.current
        
        return dataManager.allTasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            
            switch selectedTimeRange {
            case .week:
                guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
                    return false
                }
                return completedAt >= weekInterval.start && completedAt < weekInterval.end
                
            case .month:
                return calendar.isDate(completedAt, equalTo: selectedDate, toGranularity: .month)
            }
        }
    }
    
    private func getTimeDistributionData() -> [EnhancedTimeDistributionData] {
        let calendar = Calendar.current
        var data: [EnhancedTimeDistributionData] = []
        
        switch selectedTimeRange {
        case .week:
            // Show daily distribution for the week
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
                return []
            }
            
            var currentDate = weekInterval.start
            for _ in 0..<7 {
                let tasks = dataManager.allTasks.filter { task in
                    guard let completedAt = task.completedAt else { return false }
                    return calendar.isDate(completedAt, inSameDayAs: currentDate)
                }
                let hours = tasks.reduce(0.0) { $0 + ($1.actualHours ?? 0) }
                data.append(EnhancedTimeDistributionData(date: currentDate, hours: hours))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            
        case .month:
            // Show weekly distribution for the month
            guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
                return []
            }
            
            var currentDate = monthInterval.start
            while currentDate < monthInterval.end {
                guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentDate) else {
                    currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
                    continue
                }
                
                let tasks = dataManager.allTasks.filter { task in
                    guard let completedAt = task.completedAt else { return false }
                    return completedAt >= weekInterval.start && completedAt < weekInterval.end
                }
                let hours = tasks.reduce(0.0) { $0 + ($1.actualHours ?? 0) }
                data.append(EnhancedTimeDistributionData(date: weekInterval.start, hours: hours))
                
                currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
            }
        }
        
        return data
    }
    
    private func getMaxHours() -> Double {
        let data = getTimeDistributionData()
        return data.map { $0.hours }.max() ?? 1.0
    }
}

// MARK: - Data Models
struct EnhancedTimeDistributionData {
    let date: Date
    let hours: Double
}

// MARK: - Supporting Views

// MARK: - Enhanced Stat Card Component
struct EnhancedStatCard: View {
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
                .font(.system(size: 20, weight: .bold, design: .rounded))
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

// MARK: - Completed Project Card
struct CompletedProjectCard: View {
    let project: Project
    let timeSpent: Double
    let tasksCompleted: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Project color indicator
            Circle()
                .fill(Color(hex: project.color))
                .frame(width: 16, height: 16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.neuTextPrimary)
                
                Text(project.description ?? "无描述")
                    .font(.caption)
                    .foregroundColor(.neuTextSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1fh", timeSpent))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.neuAccent)
                
                Text("\(tasksCompleted) 任务")
                    .font(.caption)
                    .foregroundColor(.neuTextSecondary)
            }
        }
        .padding(16)
        .neumorphicCard(cornerRadius: 16, padding: 0)
    }
}

// MARK: - Time Distribution Bar
struct TimeDistributionBar: View {
    let date: Date
    let hours: Double
    let maxHours: Double
    let timeRange: EnhancedStatisticsView.TimeRange
    
    var body: some View {
        HStack(spacing: 12) {
            Text(formatDate())
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
                        .frame(width: geometry.size.width * CGFloat(hours / maxHours))
                        .frame(height: 20)
                }
            }
            .frame(height: 20)
            
            Text(String(format: "%.1fh", hours))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.neuTextPrimary)
                .frame(width: 40, alignment: .trailing)
        }
    }
    
    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        switch timeRange {
        case .week:
            formatter.dateFormat = "E"
        case .month:
            formatter.dateFormat = "第W周"
        }
        
        return formatter.string(from: date)
    }
}

// MARK: - Timeline View
struct TimelineView: View {
    let timeRange: EnhancedStatisticsView.TimeRange
    let selectedDate: Date
    let tasks: [Task]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            let timelineData = getTimelineData()
            
            if timelineData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "timeline.selection")
                        .font(.system(size: 32))
                        .foregroundColor(.neuTextSecondary)
                    
                    Text("该时间段内无时间线数据")
                        .font(.subheadline)
                        .foregroundColor(.neuTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .neumorphicInset(cornerRadius: 16)
            } else {
                VStack(spacing: 12) {
                    ForEach(timelineData, id: \.date) { item in
                        TimelineItem(
                            date: item.date,
                            tasks: item.tasks,
                            timeRange: timeRange
                        )
                    }
                }
                .padding(16)
                .neumorphicCard(cornerRadius: 16, padding: 0)
            }
        }
    }
    
    private func getTimelineData() -> [TimelineData] {
        let calendar = Calendar.current
        var data: [TimelineData] = []
        
        // Group tasks by date
        let tasksByDate = Dictionary(grouping: tasks) { task in
            guard let completedAt = task.completedAt else { return Date.distantPast }
            return calendar.startOfDay(for: completedAt)
        }
        
        // Sort dates and create timeline items
        let sortedDates = tasksByDate.keys.sorted()
        
        for date in sortedDates {
            if let dateTasks = tasksByDate[date], !dateTasks.isEmpty {
                data.append(TimelineData(date: date, tasks: dateTasks))
            }
        }
        
        return data
    }
}

// MARK: - Timeline Data Model
struct TimelineData {
    let date: Date
    let tasks: [Task]
}

// MARK: - Timeline Item
struct TimelineItem: View {
    let date: Date
    let tasks: [Task]
    let timeRange: EnhancedStatisticsView.TimeRange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date header
            HStack {
                Text(formatDate())
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.neuTextPrimary)
                
                Spacer()
                
                Text("\(tasks.count) 个任务")
                    .font(.caption)
                    .foregroundColor(.neuTextSecondary)
            }
            
            // Tasks list
            VStack(spacing: 6) {
                ForEach(tasks, id: \.id) { task in
                    TimelineTaskRow(task: task)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - Timeline Task Row
struct TimelineTaskRow: View {
    let task: Task
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Task status indicator
            Circle()
                .fill(task.isCompleted ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.neuTextPrimary)
                    .lineLimit(1)
                
                if let project = task.projectId.flatMap({ dataManager.getProject(byId: $0) }) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: project.color))
                            .frame(width: 6, height: 6)
                        
                        Text(project.name)
                            .font(.caption2)
                            .foregroundColor(.neuTextSecondary)
                    }
                }
            }
            
            Spacer()
            
            if let actualHours = task.actualHours {
                Text(String(format: "%.1fh", actualHours))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.neuAccent)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.neuBackground.opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    EnhancedStatisticsView()
}
