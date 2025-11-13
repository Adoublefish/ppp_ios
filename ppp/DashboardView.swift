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
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var currentTime = Date()
    
    // 清理掉所有硬编码的ScheduleItem数据，只保留eero项目的Task数据
    @State private var allScheduleItems: [ScheduleItem] = []
    
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
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    headerView
                    statsCardsView
                    HStack(alignment: .top, spacing: 0) {
                        timelineView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.trailing, 12)
                        
                        Rectangle()
                            .fill(Color(light: Color(red: 0.92, green: 0.94, blue: 0.98), dark: Color(hex: "#3A3A3C")))
                            .frame(width: 1)
                            .padding(.vertical, 16)
                        
                        tasksView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.leading, 16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                .background(Color(.systemBackground))
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            datePickerSheet
        }
        .fullScreenCover(isPresented: $showingTaskInput) {
            TaskInputView()
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
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(formatSelectedDate())
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.primary)
                
                Text(formatSelectedWeekday())
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                showingDatePicker = true
            } label: {
                Text("切换日期")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.19, green: 0.53, blue: 1.0),
                                Color(red: 0.12, green: 0.35, blue: 0.96)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
    
    private var statsCardsView: some View {
        let dailyStats = dataManager.getDailyTimeStats(for: selectedDate)
        
        return HStack(spacing: 16) {
            DashboardSummaryCard(
                value: dailyStats.formattedTotalTime,
                label: "今日时长",
                accent: Color(red: 0.10, green: 0.48, blue: 1.0)
            )
            
            DashboardSummaryCard(
                value: "\(todayCompletedTasks.count)",
                label: "完成任务",
                accent: Color(red: 0.0, green: 0.70, blue: 0.45)
            )
            
        DashboardSummaryCard(
            value: "\(dailyStats.projectStats.count)",
            label: "涉及项目",
            accent: Color(red: 1.0, green: 0.72, blue: 0.20)
        )
        
        NavigationLink(destination: TimeStatsView()) {
            DashboardSummaryCard(
                value: nil,
                label: "详细统计",
                accent: Color(red: 1.0, green: 0.35, blue: 0.47),
                icon: "chart.bar.fill"
            )
        }
        .buttonStyle(.plain)
    }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    private var datePickerSheet: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    showingDatePicker = false
                }
            
            CustomCalendarPicker(selectedDate: $selectedDate)
        }
        .presentationBackground(.clear)
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

// MARK: - Timeline View
extension DashboardView {
    private var timelineView: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading, spacing: 12) {
                Text("时间轴")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(0...24, id: \.self) { hour in
                            timelineRowView(hour: hour, isLast: hour == 24)
                                .id(hour)
                        }
                    }
                }
                .onAppear {
                    scrollToCurrentHour(using: proxy)
                }
                .onChange(of: currentTime) { _ in
                    scrollToCurrentHour(using: proxy)
                }
            }
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
    
    private func timelineRowView(hour: Int, isLast: Bool) -> some View {
        let events = getEventsForHour(hour)
        let tasks = getTasksForHour(hour)
        
        return HStack(alignment: .top, spacing: 8) {
            Text(formatHour(hour))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isCurrentHour(hour) ? Color(red: 0.16, green: 0.53, blue: 1.0) : Color.gray.opacity(0.6))
                .frame(width: 44, alignment: .trailing)
            
            VStack(spacing: 0) {
                Circle()
                    .fill(isCurrentHour(hour) ? Color(red: 0.16, green: 0.53, blue: 1.0) : Color.gray.opacity(0.35))
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isCurrentHour(hour) ? 2 : 0)
                    )
                    .shadow(color: isCurrentHour(hour) ? Color.blue.opacity(0.3) : .clear, radius: 6, x: 0, y: 4)
                
                if !isLast {
                    Rectangle()
                        .fill(Color(red: 0.90, green: 0.93, blue: 0.98))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(events, id: \.id) { event in
                    scheduleEventView(event, currentHour: hour)
                }
                
                ForEach(tasks, id: \.id) { task in
                    taskEventView(task, currentHour: hour)
                }
                
                if events.isEmpty && tasks.isEmpty {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
    }
    
    private var tasksView: some View {
        GeometryReader { proxy in
            VStack(spacing: 16) {
                allDeadlinesSection
                    .frame(height: max(proxy.size.height * 0.5, 200))
                
                todayCompletedSection
                    .frame(height: max(proxy.size.height * 0.5, 200))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: - All Deadlines Section (Right Top)
    private var allDeadlinesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("待办事项")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(pendingDeadlines.count)个")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.93, green: 0.95, blue: 1.0))
                    .clipShape(Capsule())
            }
            
            if pendingDeadlines.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color.gray.opacity(0.4))
                    Text(emptyDeadlineMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(pendingDeadlines.enumerated()), id: \.element.id) { index, task in
                            deadlineTaskRow(task, isLast: index == pendingDeadlines.count - 1)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    // MARK: - Today's Completed Tasks Section (Right Bottom)
    private var todayCompletedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日完成")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            if todayCompletedTasks.isEmpty {
                VStack(spacing: 10) {
                    Text("当日暂无完成任务")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(todayCompletedTasks.enumerated()), id: \.element.id) { index, task in
                            completedTaskRow(task, isLast: index == todayCompletedTasks.count - 1)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
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
    
    private func deadlineTaskRow(_ task: Task, isLast: Bool) -> some View {
        let projectColor: Color = {
            if let projectId = task.projectId,
               let project = dataManager.getProject(byId: projectId) {
                return Color(hex: project.color) ?? categoryColor(for: task.category)
            }
            return categoryColor(for: task.category)
        }()
        
        let (timeText, timeColor) = deadlineTimeLabel(for: task, accent: projectColor)
        
        return VStack(spacing: 0) {
            NavigationLink(destination: TaskDetailView(task: task)) {
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(projectColor)
                        .frame(width: 4)
                        .cornerRadius(2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(task.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                        
                        if !timeText.isEmpty {
                            Text(timeText)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(timeColor)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button {
                    dataManager.toggleTaskCompletion(task)
                } label: {
                    Label("完成", systemImage: "checkmark.circle.fill")
                }
                .tint(.green)
            }
            
            if !isLast {
                Divider()
                    .background(Color(.separator))
                    .padding(.leading, 16)
            }
        }
    }
    
    private func completedTaskRow(_ task: Task, isLast: Bool) -> some View {
        let projectColor: Color = {
            if let projectId = task.projectId,
               let project = dataManager.getProject(byId: projectId) {
                return Color(hex: project.color) ?? categoryColor(for: task.category)
            }
            return categoryColor(for: task.category)
        }()
        
        return VStack(spacing: 0) {
            NavigationLink(destination: TaskDetailView(task: task)) {
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(projectColor.opacity(0.6))
                        .frame(width: 4)
                        .cornerRadius(2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(task.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        if let completedAt = task.completedAt {
                            Text(formatCompletedTime(completedAt))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.16, green: 0.53, blue: 1.0))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    dataManager.toggleTaskCompletion(task)
                } label: {
                    Label("撤销", systemImage: "arrow.uturn.backward.circle")
                }
                .tint(.orange)
            }
            
            if !isLast {
                Divider()
                    .background(Color(.separator))
                    .padding(.leading, 16)
            }
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
    
    private func scrollToCurrentHour(using proxy: ScrollViewProxy) {
        let calendar = Calendar.current
        guard calendar.isDate(selectedDate, inSameDayAs: Date()) else { return }
        let currentHour = calendar.component(.hour, from: currentTime)
        withAnimation(.easeInOut(duration: 0.25)) {
            proxy.scrollTo(currentHour, anchor: .center)
        }
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
    
    private func scheduleEventView(_ event: ScheduleItem, currentHour: Int) -> some View {
        let startHour = Calendar.current.component(.hour, from: event.startTime)
        let endHour = Calendar.current.component(.hour, from: event.endTime)
        let isFirstHour = currentHour == startHour
        let isLastHour = currentHour == endHour || (currentHour == endHour - 1 && Calendar.current.component(.minute, from: event.endTime) == 0)
        let isSpanning = currentHour > startHour && currentHour < endHour
        let color = categoryColor(for: event.category)
        
        return VStack(alignment: .leading, spacing: 6) {
            if isFirstHour {
                TimelineBadge(
                    title: event.title,
                    subtitle: formatTimeRange(event.startTime, event.endTime),
                    color: color
                )
            } else if isSpanning {
                timelineSpanBlock(
                    title: event.title,
                    subtitle: hourBlockLabel(for: currentHour),
                    color: color
                )
            } else if isLastHour {
                timelineSpanBlock(
                    title: event.title,
                    subtitle: "结束 \(formatShortTime(event.endTime))",
                    color: color
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// 显示任务事件的视图
    @ViewBuilder
    private func taskEventView(_ task: Task, currentHour: Int) -> some View {
        if let startTime = task.startTime, let endTime = task.endTime {
            let startHour = Calendar.current.component(.hour, from: startTime)
            let endHour = Calendar.current.component(.hour, from: endTime)
            let isFirstHour = currentHour == startHour
            let isLastHour = currentHour == endHour || (currentHour == endHour - 1 && Calendar.current.component(.minute, from: endTime) == 0)
            let isSpanning = currentHour > startHour && currentHour < endHour
            let color = categoryColor(for: task.category)
            
            if isFirstHour {
                NavigationLink(destination: TaskDetailView(task: task)) {
                    TimelineBadge(
                        title: task.title,
                        subtitle: formatTimeRange(startTime, endTime),
                        color: color
                    )
                }
                .buttonStyle(.plain)
            } else if isSpanning {
                timelineSpanBlock(
                    title: task.title,
                    subtitle: hourBlockLabel(for: currentHour),
                    color: color
                )
            } else if isLastHour {
                timelineSpanBlock(
                    title: task.title,
                    subtitle: "结束 \(formatShortTime(endTime))",
                    color: color
                )
            } else {
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }
    
    private func timelineSpanBlock(title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(color)
                .frame(width: 3)
                .cornerRadius(1.5)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.opacity(0.12))
        )
    }
    
    private func hourBlockLabel(for hour: Int) -> String {
        let nextHour = min(hour + 1, 24)
        return String(format: "%02d:00 - %02d:00", hour, nextHour)
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
    
    private func formatCompletedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: date)) 完成"
    }

    private func deadlineTimeLabel(for task: Task, accent: Color) -> (String, Color) {
        guard let dueDate = task.dueDate else {
            return ("", accent)
        }
        
        let calendar = Calendar.current
        let now = Date()
        let isSelectedToday = calendar.isDate(selectedDate, inSameDayAs: now)
        
        if isSelectedToday, dueDate < currentTime {
            return ("Overdue", Color(red: 1.0, green: 0.35, blue: 0.36))
        }
        
        if calendar.isDate(dueDate, inSameDayAs: selectedDate) {
            return (formatDueTime(dueDate), accent)
        }
        
        return (formatDueDate(dueDate), Color.secondary)
    }

    private func formatTimeRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let startText = formatter.string(from: start).uppercased()
        let endText = formatter.string(from: end).uppercased()
        return "\(startText) - \(endText)"
    }
    
    private func formatShortTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    

    
    private func formatDueTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date).uppercased()
    }
    

    
}

// MARK: - Helper Functions
extension DashboardView {
    private func categoryColor(for category: TaskCategory) -> Color {
        switch category {
        case .meeting: return .blue
        case .review: return .green
        case .development: return .purple
        case .design: return .pink
        case .communication: return .orange
        case .presentation: return .red
        case .milestone: return .mint
        case .planning: return .teal
        case .testing: return .cyan
        case .documentation: return .brown
        case .custom:
            return .red
        }
    }
}

// MARK: - Subviews
private struct DashboardSummaryCard: View {
    let value: String?
    let label: String
    let accent: Color
    let icon: String?
    
    init(value: String?, label: String, accent: Color, icon: String? = nil) {
        self.value = value?.isEmpty == false ? value : nil
        self.label = label
        self.accent = accent
        self.icon = icon
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Group {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(accent)
                } else if let value = value {
                    Text(value)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(accent)
                } else {
                    Text(" ")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.clear)
                }
            }
            .frame(height: 28)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .frame(minHeight: 88)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(light: Color(red: 0.96, green: 0.97, blue: 1.0), dark: Color(hex: "#2C2C2E")))
        )
    }
}

private struct TimelineBadge: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.12))
        )
        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 3)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    DashboardView()
}

// MARK: - Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
