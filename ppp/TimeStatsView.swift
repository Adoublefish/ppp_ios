//
//  TimeStatsView.swift
//  ppp
//
//  Created by Kiro on 2025-01-22.
//

import SwiftUI

struct TimeStatsView: View {
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var selectedPeriod: TimePeriod = .today
    @State private var selectedProject = "所有项目"
    
    enum TimePeriod: String, CaseIterable {
        case today = "今天"
        case week = "本周"
        case month = "本月"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Period selector
                periodSelectorSection
                
                // Time entries list
                timeEntriesSection
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("时间跟踪")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Project filter dropdown
            Menu {
                Button("所有项目") {
                    selectedProject = "所有项目"
                }
                
                ForEach(getAvailableProjects(), id: \.self) { project in
                    Button(project) {
                        selectedProject = project
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selectedProject)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Period Selector Section
    private var periodSelectorSection: some View {
        HStack(spacing: 0) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button(action: {
                    selectedPeriod = period
                }) {
                    Text(period.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedPeriod == period ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedPeriod == period ? 
                            Color(.systemBackground) : Color.clear
                        )
                        .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    // MARK: - Time Entries Section
    private var timeEntriesSection: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Period header
                HStack {
                    Text(selectedPeriod.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Time entries
                ForEach(getTimeEntries()) { entry in
                    TimeEntryRow(entry: entry)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
                
                if getTimeEntries().isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("暂无时间记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("完成任务后将显示时间跟踪记录")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getAvailableProjects() -> [String] {
        // Return list of project names from data manager
        return dataManager.allProjects.map { $0.name }
    }
    
    private func getTimeEntries() -> [TimeEntry] {
        // Mock data for now - replace with actual data from TaskDataManager
        let mockEntries = [
            TimeEntry(
                id: UUID(),
                projectName: "Mobile App",
                taskDescription: "完成登录页面设计",
                duration: "1h 30m",
                timeRange: "11:27 - 12:57",
                color: .blue,
                date: Date()
            ),
            TimeEntry(
                id: UUID(),
                projectName: "Mobile App",
                taskDescription: "完成用户登录和注册功能",
                duration: "2h 0m",
                timeRange: "09:27 - 11:27",
                color: .blue,
                date: Date()
            ),
            TimeEntry(
                id: UUID(),
                projectName: "Web Platform",
                taskDescription: "优化查询性能",
                duration: "3h 0m",
                timeRange: "13:27 - 16:27",
                color: .green,
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            )
        ]
        
        // Filter by selected period and project
        return mockEntries.filter { entry in
            let matchesProject = selectedProject == "所有项目" || entry.projectName == selectedProject
            let matchesPeriod = isEntryInSelectedPeriod(entry.date)
            return matchesProject && matchesPeriod
        }
    }
    
    private func isEntryInSelectedPeriod(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .today:
            return calendar.isDate(date, inSameDayAs: now)
        case .week:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return date >= weekStart
        case .month:
            let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return date >= monthStart
        }
    }
    

}

// MARK: - Supporting Views and Models

struct TimeEntry: Identifiable {
    let id: UUID
    let projectName: String
    let taskDescription: String
    let duration: String
    let timeRange: String
    let color: Color
    let date: Date
}

struct TimeEntryRow: View {
    let entry: TimeEntry
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Project color indicator
                Circle()
                    .fill(entry.color)
                    .frame(width: 12, height: 12)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Task title and project
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.taskDescription)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(entry.projectName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Duration and time range
                VStack(alignment: .trailing, spacing: 4) {
                    Text(entry.duration)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(entry.timeRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}



// MARK: - Preview
struct TimeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        TimeStatsView()
    }
}