//
//  DashboardView.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false

    @State private var showingTaskInput = false
    @State private var selectedTask: Task? = nil
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    // 清理掉所有硬编码的ScheduleItem数据，只保留eero项目的Task数据
    @State private var allScheduleItems: [ScheduleItem] = []
    
    @State private var currentTime = Date()
    
    // Computed properties for filtered data based on selected date
    private var todaySchedule: [ScheduleItem] {
        let calendar = Calendar.current
        return allScheduleItems.filter { item in
            calendar.isDate(item.startTime, inSameDayAs: selectedDate)
        }
    }
    
    /// 今日时间段任务 (有startTime和endTime的Task)
    private var todayTimeRangeTasks: [Task] {
        let calendar = Calendar.current
        return dataManager.allTasks.filter { task in
            guard let startTime = task.startTime else { return false }
            return calendar.isDate(startTime, inSameDayAs: selectedDate) && task.isTimeRangeTask
        }
    }
    
    private var pendingDeadlines: [Task] {
        // Use selected date as the baseline instead of current date
        let calendar = Calendar.current
        let startOfSelectedDate = calendar.startOfDay(for: selectedDate)
        
        return dataManager.allTasks
            .filter { task in
                // 只显示有截止日期且未完成的任务
                guard let dueDate = task.dueDate else { return false }
                return !task.isCompleted && dueDate >= startOfSelectedDate
            }
            .sorted { task1, task2 in
                // Sort by due date (nearest first)
                guard let due1 = task1.dueDate, let due2 = task2.dueDate else { return false }
                return due1 < due2
            }
    }
    
    private var todayCompletedTasks: [Task] {
        let calendar = Calendar.current
        return dataManager.allTasks
            .filter { task in
                task.isCompleted &&
                task.completedAt != nil &&
                calendar.isDate(task.completedAt!, inSameDayAs: selectedDate)
            }
            .sorted { task1, task2 in
                guard let completed1 = task1.completedAt,
                      let completed2 = task2.completedAt else { return false }
                return completed1 > completed2
            }
    }
    
    var body: some View {
        ZStack {
            // Main Content
            VStack(spacing: 0) {
                // Dashboard Content
                VStack(spacing: 0) {
                    // Simple Header
                    headerView
                    
                    // Main Content
                    HStack(spacing: 0) {
                        // Left Timeline (35% width)
                        timelineView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.backgroundPrimary.opacity(0.4))
                        
                        // Right Content (65% width)
                        VStack(spacing: 16) {
                            // All Deadlines Section (Top)
                            allDeadlinesSection
                            
                            // Today's Completed Tasks Section (Bottom)
                            todayCompletedSection
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.backgroundSecondary)
                    }
                }
            }
            .background(Color.backgroundSecondary)
        }
        .sheet(isPresented: $showingDatePicker) {
            datePickerSheet
        }
        .fullScreenCover(isPresented: $showingTaskInput) {
            TaskInputView()
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }
}

// MARK: - Header
extension DashboardView {
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formatSelectedDate())
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(formatSelectedWeekday())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("切换日期") {
                    showingDatePicker = true
                }
                .font(.subheadline)
                .neumorphicButton(color: .neuAccent, textColor: .white)
            }
            
            // Daily time stats
            dailyTimeStatsView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.backgroundSecondary)
    }
    
    private var dailyTimeStatsView: some View {
        let dailyStats = dataManager.getDailyTimeStats(for: selectedDate)
        
        return HStack(spacing: 16) {
            // Total time for the day
            VStack(spacing: 4) {
                Text(dailyStats.formattedTotalTime)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.softTeal)
                
                Text("今日时长")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.softTeal.opacity(0.1))
            .cornerRadius(8)
            
            // Completed tasks count
            VStack(spacing: 4) {
                Text("\(dailyStats.completedTasks)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text("完成任务")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            
            // Project count for the day
            VStack(spacing: 4) {
                Text("\(dailyStats.projectStats.count)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Text("涉及项目")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            
            // View detailed stats button
            NavigationLink(destination: TimeStatsView()) {
                VStack(spacing: 4) {
                    Image(systemName: "chart.bar")
                        .font(.title3)
                        .foregroundColor(.softPink)
                    
                    Text("详细统计")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.softPink.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var datePickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("选择日期")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                DatePicker(
                    "选择日期",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal, 20)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button("取消") {
                        showingDatePicker = false
                    }
                    .font(.subheadline)
                    .neumorphicButton(color: .neuBackground, textColor: .neuTextPrimary)
                    
                    Button("确定") {
                        showingDatePicker = false
                        // Data automatically updates through computed properties
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .neumorphicButton(color: .neuAccent, textColor: .white)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemBackground))
        }
        .presentationDetents([.medium, .large])
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }
    
    private func formatSelectedWeekday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Timeline View (Simple Static)
extension DashboardView {
    private var timelineView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Timeline Header
            HStack {
                Text("时间轴")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Timeline
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(8..<19, id: \.self) { hour in
                        timelineRowView(hour: hour)
                    }
                }
            }
        }
    }
    
    private func timelineRowView(hour: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Time label
            Text(formatHour(hour))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
            
            // Timeline dot and line
            VStack(spacing: 0) {
                Circle()
                    .fill(isCurrentHour(hour) ? Color.softTeal : Color(.systemGray4))
                    .frame(width: isCurrentHour(hour) ? 8 : 6, height: isCurrentHour(hour) ? 8 : 6)
                
                if hour < 18 {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 1, height: 48)
                }
            }
            
            // Event content area
            VStack(alignment: .leading, spacing: 4) {
                // Display ScheduleItems
                ForEach(getEventsForHour(hour), id: \.id) { event in
                    scheduleEventView(event, currentHour: hour)
                }
                
                // Display Time Range Tasks
                ForEach(getTasksForHour(hour), id: \.id) { task in
                    taskEventView(task, currentHour: hour)
                }
                
                if getEventsForHour(hour).isEmpty && getTasksForHour(hour).isEmpty {
                    Spacer()
                        .frame(height: 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 48)
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
    }
    
    private func scheduleEventView(_ event: ScheduleItem, currentHour: Int) -> some View {
        let startHour = Calendar.current.component(.hour, from: event.startTime)
        let endHour = Calendar.current.component(.hour, from: event.endTime)
        let isFirstHour = currentHour == startHour
        let isLastHour = currentHour == endHour || (currentHour == endHour - 1 && Calendar.current.component(.minute, from: event.endTime) == 0)
        let isSpanning = currentHour > startHour && currentHour < endHour
        
        return HStack(spacing: 8) {
            Rectangle()
                .fill(categoryColor(for: event.category))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 2) {
                if isFirstHour {
                    Text(event.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(event.duration) • \(event.location ?? "")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else if isSpanning {
                    Text("↕ \(event.title) 进行中")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else if isLastHour {
                    Text("↑ \(event.title) 结束")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, isFirstHour ? 6 : 3)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(categoryColor(for: event.category).opacity(isFirstHour ? 0.15 : 0.08))
                .overlay(
                    // Left border for spanning events
                    Rectangle()
                        .fill(categoryColor(for: event.category))
                        .frame(width: 2)
                        .opacity(isSpanning || isLastHour ? 0.6 : 0),
                    alignment: .leading
                )
        )
    }
    
    /// 显示任务事件的视图
    private func taskEventView(_ task: Task, currentHour: Int) -> some View {
        guard let startTime = task.startTime, let endTime = task.endTime else {
            return AnyView(EmptyView())
        }
        
        let startHour = Calendar.current.component(.hour, from: startTime)
        let endHour = Calendar.current.component(.hour, from: endTime)
        let isFirstHour = currentHour == startHour
        let isLastHour = currentHour == endHour || (currentHour == endHour - 1 && Calendar.current.component(.minute, from: endTime) == 0)
        let isSpanning = currentHour > startHour && currentHour < endHour
        
        return AnyView(
            Button(action: {
                selectedTask = task
            }) {
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(categoryColor(for: task.category))
                        .frame(width: 4)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if isFirstHour {
                            Text(task.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            if let duration = task.duration {
                                Text("\(duration) • 任务")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        } else if isSpanning {
                            Text("↕ \(task.title) 进行中")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else if isLastHour {
                            Text("↑ \(task.title) 结束")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, isFirstHour ? 6 : 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(categoryColor(for: task.category).opacity(isFirstHour ? 0.15 : 0.08))
                        .overlay(
                            // Left border for spanning events
                            Rectangle()
                                .fill(categoryColor(for: task.category))
                                .frame(width: 2)
                                .opacity(isSpanning || isLastHour ? 0.6 : 0),
                            alignment: .leading
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        )
    }
    
    private func getEventsForHour(_ hour: Int) -> [ScheduleItem] {
        return todaySchedule.filter { event in
            let startHour = Calendar.current.component(.hour, from: event.startTime)
            let endHour = Calendar.current.component(.hour, from: event.endTime)
            let endMinute = Calendar.current.component(.minute, from: event.endTime)
            
            // Event spans this hour if:
            // 1. It starts at this hour
            // 2. It's ongoing during this hour
            // 3. It ends during this hour (but not at minute 0)
            return hour >= startHour && (hour < endHour || (hour == endHour && endMinute > 0))
        }
    }
    
    /// 获取指定小时的时间段任务
    private func getTasksForHour(_ hour: Int) -> [Task] {
        return todayTimeRangeTasks.filter { task in
            guard let startTime = task.startTime, let endTime = task.endTime else { return false }
            let startHour = Calendar.current.component(.hour, from: startTime)
            let endHour = Calendar.current.component(.hour, from: endTime)
            let endMinute = Calendar.current.component(.minute, from: endTime)
            
            // Task spans this hour if:
            // 1. It starts at this hour
            // 2. It's ongoing during this hour
            // 3. It ends during this hour (but not at minute 0)
            return hour >= startHour && (hour < endHour || (hour == endHour && endMinute > 0))
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        return "\(hour):00"
    }
    
    private func isCurrentHour(_ hour: Int) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(selectedDate, inSameDayAs: Date()) && 
               calendar.component(.hour, from: currentTime) == hour
    }
}

// MARK: - All Deadlines Section (Right Top)
extension DashboardView {
    private var allDeadlinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("待办事项")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(pendingDeadlineSubtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(pendingDeadlines.count)个")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Deadline Tasks List
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(pendingDeadlines) { task in
                        deadlineTaskRow(task)
                    }
                    
                    if pendingDeadlines.isEmpty {
                        Text(emptyDeadlineMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    }
                }
            }
        }
    }
    
    // Helper computed properties for dynamic text
    private var pendingDeadlineSubtitle: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(selectedDate, inSameDayAs: now) {
            return "从今天开始"
        } else if selectedDate > now {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            formatter.locale = Locale(identifier: "zh_CN")
            return "从\(formatter.string(from: selectedDate))开始"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            formatter.locale = Locale(identifier: "zh_CN")
            return "从\(formatter.string(from: selectedDate))开始"
        }
    }
    
    private var emptyDeadlineMessage: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(selectedDate, inSameDayAs: now) {
            return "暂无待办任务"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            formatter.locale = Locale(identifier: "zh_CN")
            return "\(formatter.string(from: selectedDate))之后暂无任务"
        }
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "今天 \(formatter.string(from: date))"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now)!) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "明天 \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }
    
    private func deadlineTaskRow(_ task: Task) -> some View {
        let urgencyColor: Color = {
            guard let dueDate = task.dueDate else { return .secondary }
            return getUrgencyColor(for: dueDate)
        }()
        
        return Button(action: {
            selectedTask = task
        }) {
            HStack(spacing: 12) {
                // Completion checkbox
                Button(action: {
                    dataManager.toggleTaskCompletion(task)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(task.isCompleted ? .green : .secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Task content - 显示title、description、团队和due date
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // 团队和截止日期信息
                    HStack(spacing: 8) {
                        // 显示所属团队
                        if let projectId = task.projectId,
                           let project = dataManager.getProject(byId: projectId),
                           let team = dataManager.getTeamByProjectId(projectId) {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption2)
                                    .foregroundColor(.softTeal)
                                Text(team.name)
                                    .font(.caption2)
                                    .foregroundColor(.softTeal)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.softTeal.opacity(0.1))
                            .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        // 显示截止日期
                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                    .foregroundColor(urgencyColor)
                                Text(formatDueDate(dueDate))
                                    .font(.caption2)
                                    .foregroundColor(urgencyColor)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .neumorphism(cornerRadius: 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Today's Completed Tasks Section (Right Bottom)
extension DashboardView {
    private var todayCompletedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Text("今日完成")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text("\(todayCompletedTasks.count)个")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Completed Tasks List
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(todayCompletedTasks) { task in
                        completedTaskRow(task)
                    }
                    
                    if todayCompletedTasks.isEmpty {
                        Text("当日暂无完成任务")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    }
                }
            }
        }
    }
    
    private func completedTaskRow(_ task: Task) -> some View {
        Button(action: {
            selectedTask = task
        }) {
            HStack(spacing: 12) {
                // Completion checkbox (clickable to uncheck)
                Button(action: {
                    dataManager.toggleTaskCompletion(task)
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
                .buttonStyle(PlainButtonStyle())
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough()
                    .foregroundColor(.secondary)
                
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Text(task.category.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .foregroundColor(.green)
                        
                        if let completedAt = task.completedAt {
                            Text(formatCompletedTime(completedAt))
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .neumorphism(cornerRadius: 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



// MARK: - Helper Functions
extension DashboardView {
    // Dynamic urgency calculation based on the actual range of all deadlines
    private func calculateUrgency(for dueDate: Date) -> Double {
        let now = Date()
        let timeUntilDue = dueDate.timeIntervalSince(now)
        
        // If overdue, maximum urgency
        if timeUntilDue <= 0 {
            return 1.0
        }
        
        // Get all pending deadline times to establish the range
        let allPendingTimes = pendingDeadlines.compactMap { task in
            task.dueDate?.timeIntervalSince(now)
        }
        
        guard let minTime = allPendingTimes.min(),
              let maxTime = allPendingTimes.max(),
              maxTime > minTime else {
            return 0.5 // Default middle urgency if no range
        }
        
        // Normalize the time within the range (0 = furthest, 1 = nearest)
        let normalizedPosition = 1.0 - (timeUntilDue - minTime) / (maxTime - minTime)
        
        // Apply a slight curve to make near deadlines more prominent
        // Using a square root curve to give more emphasis to urgent items
        return sqrt(max(0.0, min(1.0, normalizedPosition)))
    }
    
    // Dynamic color interpolation from red (urgent) to yellow (distant)
    private func getUrgencyColor(for dueDate: Date) -> Color {
        let urgency = calculateUrgency(for: dueDate)
        
        // Smooth interpolation between red and yellow
        // Red: (1.0, 0.0, 0.0), Yellow: (1.0, 1.0, 0.0)
        let red: Double = 1.0
        let green: Double = 1.0 - urgency  // 0 for most urgent (red), 1 for least urgent (yellow)
        let blue: Double = 0.0
        
        return Color(red: red, green: green, blue: blue)
    }
    
    // Alternative smoother color interpolation with better visual progression
    private func getUrgencyColorSmooth(for dueDate: Date) -> Color {
        let urgency = calculateUrgency(for: dueDate)
        
        // Create a smooth transition from red to orange to yellow
        if urgency >= 0.8 {
            // Very urgent: Pure red to red-orange
            let progress = (urgency - 0.8) / 0.2
            let green = 0.0 + (0.3 * (1.0 - progress))
            return Color(red: 1.0, green: green, blue: 0.0)
        } else if urgency >= 0.5 {
            // Moderately urgent: Red-orange to orange
            let progress = (urgency - 0.5) / 0.3
            let green = 0.3 + (0.35 * (1.0 - progress))
            return Color(red: 1.0, green: green, blue: 0.0)
        } else {
            // Less urgent: Orange to yellow
            let progress = urgency / 0.5
            let green = 0.65 + (0.35 * (1.0 - progress))
            return Color(red: 1.0, green: green, blue: 0.0)
        }
    }
    
    private func categoryColor(for category: TaskCategory) -> Color {
        switch category {
        case .meeting: return .softTeal
        case .review: return .green
        case .development: return .softPink
        case .design: return .pink
        case .communication: return .orange
        case .presentation: return .red
        case .milestone: return .softMint
        case .planning: return .teal
        case .testing: return .cyan
        case .documentation: return .brown
        case .custom:
            return .red
        }
    }
    
    private func formatRelativeDueTime(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "\(formatter.string(from: date))"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: selectedDate)!) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "明天 \(formatter.string(from: date))"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: selectedDate)!) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }
    
    private func formatAbsoluteDueTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()  // Always use current date for relative time display
        
        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "今天 \(formatter.string(from: date))"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now)!) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "明天 \(formatter.string(from: date))"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now)!) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "昨天 \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日 HH:mm"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }
    
    private func formatCompletedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: date)) 完成"
    }
}

#Preview {
    DashboardView()
}
