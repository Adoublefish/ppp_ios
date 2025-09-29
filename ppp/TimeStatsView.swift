//
//  TimeStatsView.swift
//  ppp
//
//  Created by Kiro on 2025-01-22.
//

import SwiftUI
import Charts

struct TimeStatsView: View {
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedDate = Date()
    
    enum TimePeriod: String, CaseIterable {
        case day = "日"
        case week = "周"
        case month = "月"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with period selector
                    headerSection
                    
                    // Time overview cards
                    timeOverviewSection
                    
                    // Project breakdown
                    projectBreakdownSection
                    
                    // Time chart
                    timeChartSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("时间统计")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Period selector
            HStack(spacing: 0) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                    }) {
                        Text(period.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedPeriod == period ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedPeriod == period ? 
                                Color.blue : Color(.systemGray6)
                            )
                    }
                }
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            
            // Date picker
            DatePicker(
                "选择日期",
                selection: $selectedDate,
                displayedComponents: selectedPeriod == .day ? [.date] : [.date]
            )
            .datePickerStyle(CompactDatePickerStyle())
        }
    }
    
    // MARK: - Time Overview Section
    private var timeOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("时间概览")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                // Total time card
                TimeStatsCard(
                    title: "总时长",
                    value: getTotalTime(),
                    icon: "clock.fill",
                    color: .blue
                )
                
                // Completed tasks card
                TimeStatsCard(
                    title: "完成任务",
                    value: "\(getCompletedTasksCount())",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                // Average daily time card
                TimeStatsCard(
                    title: "日均时长",
                    value: getAverageDailyTime(),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
                
                // Efficiency card
                TimeStatsCard(
                    title: "效率指数",
                    value: getEfficiencyScore(),
                    icon: "speedometer",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Project Breakdown Section
    private var projectBreakdownSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("项目时间分布")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(getProjectStats()) { projectStat in
                    ProjectTimeRow(
                        projectName: getProjectName(projectStat.projectId),
                        estimatedTime: projectStat.formattedEstimatedTime,
                        actualTime: projectStat.formattedActualTime,
                        efficiency: projectStat.efficiency,
                        completedTasks: projectStat.completedTasks,
                        totalTasks: projectStat.totalTasks,
                        color: getProjectColor(projectStat.projectId)
                    )
                }
                
                if getProjectStats().isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("暂无项目时间数据")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("完成任务后将显示时间统计")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Time Chart Section
    private var timeChartSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("时间趋势")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 16) {
                if #available(iOS 16.0, *) {
                    Chart(getChartData()) { data in
                        BarMark(
                            x: .value("日期", data.date),
                            y: .value("时长", data.hours)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                } else {
                    // Fallback for iOS 15
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("图表功能需要 iOS 16+")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getTotalTime() -> String {
        switch selectedPeriod {
        case .day:
            let stats = dataManager.getDailyTimeStats(for: selectedDate)
            return stats.formattedTotalTime
        case .week:
            let stats = dataManager.getWeeklyTimeStats(for: selectedDate)
            return stats.formattedTotalTime
        case .month:
            let stats = dataManager.getMonthlyTimeStats(for: selectedDate)
            return stats.formattedTotalTime
        }
    }
    
    private func getCompletedTasksCount() -> Int {
        switch selectedPeriod {
        case .day:
            let stats = dataManager.getDailyTimeStats(for: selectedDate)
            return stats.completedTasks
        case .week:
            let stats = dataManager.getWeeklyTimeStats(for: selectedDate)
            return stats.dailyStats.reduce(0) { $0 + $1.completedTasks }
        case .month:
            let stats = dataManager.getMonthlyTimeStats(for: selectedDate)
            return stats.weeklyStats.reduce(0) { $0 + $1.dailyStats.reduce(0) { $0 + $1.completedTasks } }
        }
    }
    
    private func getAverageDailyTime() -> String {
        switch selectedPeriod {
        case .day:
            return getTotalTime()
        case .week:
            let stats = dataManager.getWeeklyTimeStats(for: selectedDate)
            let avgHours = stats.averageDailyHours
            return formatHours(avgHours)
        case .month:
            let stats = dataManager.getMonthlyTimeStats(for: selectedDate)
            let avgHours = stats.averageDailyHours
            return formatHours(avgHours)
        }
    }
    
    private func getEfficiencyScore() -> String {
        let projectStats = getProjectStats()
        guard !projectStats.isEmpty else { return "N/A" }
        
        let totalEfficiency = projectStats.reduce(0) { $0 + $1.efficiency }
        let avgEfficiency = totalEfficiency / Double(projectStats.count)
        
        return String(format: "%.1f%%", avgEfficiency * 100)
    }
    
    private func getProjectStats() -> [ProjectTimeStats] {
        switch selectedPeriod {
        case .day:
            let stats = dataManager.getDailyTimeStats(for: selectedDate)
            return stats.projectStats
        case .week:
            let stats = dataManager.getWeeklyTimeStats(for: selectedDate)
            return stats.projectStats
        case .month:
            let stats = dataManager.getMonthlyTimeStats(for: selectedDate)
            return stats.projectStats
        }
    }
    
    private func getProjectName(_ projectId: UUID) -> String {
        return dataManager.getProject(byId: projectId)?.name ?? "未知项目"
    }
    
    private func getProjectColor(_ projectId: UUID) -> Color {
        let colorHex = dataManager.getProject(byId: projectId)?.color ?? "#3B82F6"
        return Color(hex: colorHex)
    }
    
    private func formatHours(_ hours: Double) -> String {
        if hours >= 1 {
            return String(format: "%.1fh", hours)
        } else {
            let minutes = Int(hours * 60)
            return "\(minutes)m"
        }
    }
    
    private func getChartData() -> [ChartDataPoint] {
        switch selectedPeriod {
        case .day:
            // For day view, show hourly breakdown (mock data)
            return (0..<24).map { hour in
                ChartDataPoint(
                    date: Calendar.current.date(byAdding: .hour, value: hour, to: Calendar.current.startOfDay(for: selectedDate)) ?? selectedDate,
                    hours: Double.random(in: 0...2)
                )
            }
        case .week:
            let stats = dataManager.getWeeklyTimeStats(for: selectedDate)
            return stats.dailyStats.map { dailyStat in
                ChartDataPoint(date: dailyStat.date, hours: dailyStat.totalHours)
            }
        case .month:
            let stats = dataManager.getMonthlyTimeStats(for: selectedDate)
            return stats.weeklyStats.map { weeklyStat in
                ChartDataPoint(date: weeklyStat.weekStart, hours: weeklyStat.totalHours)
            }
        }
    }
}

// MARK: - Supporting Views

struct TimeStatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ProjectTimeRow: View {
    let projectName: String
    let estimatedTime: String
    let actualTime: String
    let efficiency: Double
    let completedTasks: Int
    let totalTasks: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Project indicator
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text(projectName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(completedTasks)/\(totalTasks)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("预估: \(estimatedTime)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("实际: \(actualTime)")
                        .font(.caption2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("效率")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f%%", efficiency * 100))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(efficiency <= 1.0 ? .green : .orange)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * min(efficiency, 1.0), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
}



// MARK: - Preview
struct TimeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        TimeStatsView()
    }
}