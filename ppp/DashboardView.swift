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
    @State private var selectedTab = 0
    
    // All fake data for different dates
    @State private var allScheduleItems: [ScheduleItem] = {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: today)!
        let twoWeeksLater = calendar.date(byAdding: .weekOfYear, value: 2, to: today)!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: today)!
        
        return [
            // Today's schedule
            ScheduleItem(
                title: "团队晨会",
                description: "每日站会，同步项目进展",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!,
                endTime: calendar.date(bySettingHour: 9, minute: 30, second: 0, of: today)!,
                category: .meeting,
                location: "会议室A",
                createdAt: calendar.date(byAdding: .day, value: -2, to: today)!
            ),
            ScheduleItem(
                title: "产品设计评审",
                description: "UI/UX设计方案评审会议",
                startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today)!,
                endTime: calendar.date(bySettingHour: 11, minute: 30, second: 0, of: today)!,
                category: .design,
                location: "会议室B",
                createdAt: calendar.date(byAdding: .day, value: -1, to: today)!
            ),
            ScheduleItem(
                title: "客户需求讨论",
                description: "与客户沟通项目需求细节",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: today)!,
                endTime: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today)!,
                category: .communication,
                location: "线上会议",
                createdAt: calendar.date(byAdding: .hour, value: -3, to: today)!
            ),
            ScheduleItem(
                title: "技术方案会议",
                description: "讨论系统架构和技术选型",
                startTime: calendar.date(bySettingHour: 15, minute: 30, second: 0, of: today)!,
                endTime: calendar.date(bySettingHour: 16, minute: 30, second: 0, of: today)!,
                category: .meeting,
                location: "技术部",
                createdAt: today
            ),
            ScheduleItem(
                title: "项目进度汇报",
                description: "向管理层汇报项目当前状态",
                startTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: today)!,
                endTime: calendar.date(bySettingHour: 17, minute: 30, second: 0, of: today)!,
                category: .presentation,
                location: "董事会议室",
                createdAt: today
            ),
            
            // Yesterday's schedule
            ScheduleItem(
                title: "代码评审会议",
                description: "审查上周提交的代码",
                startTime: calendar.date(bySettingHour: 9, minute: 30, second: 0, of: yesterday)!,
                endTime: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: yesterday)!,
                category: .review,
                location: "开发部",
                createdAt: calendar.date(byAdding: .day, value: -3, to: today)!
            ),
            ScheduleItem(
                title: "客户演示",
                description: "向客户展示最新功能",
                startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: yesterday)!,
                endTime: calendar.date(bySettingHour: 15, minute: 30, second: 0, of: yesterday)!,
                category: .presentation,
                location: "会议室C",
                createdAt: calendar.date(byAdding: .day, value: -2, to: today)!
            ),
            
            // Tomorrow's schedule
            ScheduleItem(
                title: "项目启动会",
                description: "新项目启动讨论",
                startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: tomorrow)!,
                endTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: tomorrow)!,
                category: .planning,
                location: "大会议室",
                createdAt: today
            ),
            ScheduleItem(
                title: "团队建设活动",
                description: "季度团队聚餐",
                startTime: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: tomorrow)!,
                endTime: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: tomorrow)!,
                category: .planning,
                location: "餐厅",
                createdAt: today
            ),
            
            // Day after tomorrow's schedule
            ScheduleItem(
                title: "用户研究会议",
                description: "分析用户反馈和使用数据",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dayAfterTomorrow)!,
                endTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: dayAfterTomorrow)!,
                category: .review,
                location: "研究室",
                createdAt: today
            ),
            ScheduleItem(
                title: "技术培训",
                description: "新技术栈培训课程",
                startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: dayAfterTomorrow)!,
                endTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: dayAfterTomorrow)!,
                category: .development,
                location: "培训室",
                createdAt: today
            ),
            
            // Next week's schedule (Monday)
            ScheduleItem(
                title: "周例会",
                description: "每周项目进度汇报",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: nextWeek)!,
                endTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: nextWeek)!,
                category: .meeting,
                location: "会议室A",
                createdAt: today
            ),
            ScheduleItem(
                title: "产品路线图讨论",
                description: "Q4产品发布计划讨论",
                startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: nextWeek)!,
                endTime: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: nextWeek)!,
                category: .planning,
                location: "策略室",
                createdAt: today
            ),
            
            // Next week Tuesday
            ScheduleItem(
                title: "客户需求评审",
                description: "新客户需求可行性分析",
                startTime: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 1, to: nextWeek)!)!,
                endTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: nextWeek)!)!,
                category: .review,
                location: "会议室B",
                createdAt: today
            ),
            ScheduleItem(
                title: "技术架构讨论",
                description: "微服务架构迁移方案",
                startTime: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: nextWeek)!)!,
                endTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: nextWeek)!)!,
                category: .development,
                location: "技术部",
                createdAt: today
            ),
            
            // Next week Wednesday
            ScheduleItem(
                title: "设计评审会",
                description: "新版本UI设计终审",
                startTime: calendar.date(bySettingHour: 9, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 2, to: nextWeek)!)!,
                endTime: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 2, to: nextWeek)!)!,
                category: .design,
                location: "设计部",
                createdAt: today
            ),
            ScheduleItem(
                title: "季度总结会议",
                description: "Q3工作总结和Q4规划",
                startTime: calendar.date(bySettingHour: 14, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 2, to: nextWeek)!)!,
                endTime: calendar.date(bySettingHour: 17, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 2, to: nextWeek)!)!,
                category: .presentation,
                location: "大会议室",
                createdAt: today
            ),
            
            // Next week Thursday
            ScheduleItem(
                title: "用户测试会议",
                description: "新功能用户体验测试",
                startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 3, to: nextWeek)!)!,
                endTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 3, to: nextWeek)!)!,
                category: .testing,
                location: "用户研究室",
                createdAt: today
            ),
            ScheduleItem(
                title: "合作伙伴会议",
                description: "讨论合作项目进展",
                startTime: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 3, to: nextWeek)!)!,
                endTime: calendar.date(bySettingHour: 16, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 3, to: nextWeek)!)!,
                category: .communication,
                location: "线上会议",
                createdAt: today
            ),
            
            // Next week Friday
            ScheduleItem(
                title: "代码发布会议",
                description: "版本发布前最终检查",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 4, to: nextWeek)!)!,
                endTime: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 4, to: nextWeek)!)!,
                category: .development,
                location: "开发部",
                createdAt: today
            ),
            ScheduleItem(
                title: "团队聚餐",
                description: "庆祝项目里程碑达成",
                startTime: calendar.date(bySettingHour: 18, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 4, to: nextWeek)!)!,
                endTime: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 4, to: nextWeek)!)!,
                category: .planning,
                location: "餐厅",
                createdAt: today
            ),
            
            // Two weeks later (Monday)
            ScheduleItem(
                title: "月度全员大会",
                description: "公司月度业务汇报",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: twoWeeksLater)!,
                endTime: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: twoWeeksLater)!,
                category: .presentation,
                location: "礼堂",
                createdAt: today
            ),
            ScheduleItem(
                title: "新员工培训",
                description: "公司文化和流程培训",
                startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: twoWeeksLater)!,
                endTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: twoWeeksLater)!,
                category: .planning,
                location: "培训室",
                createdAt: today
            ),
            
            // Two weeks later Tuesday
            ScheduleItem(
                title: "技术分享会",
                description: "最新技术趋势分享",
                startTime: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: twoWeeksLater)!)!,
                endTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: twoWeeksLater)!)!,
                category: .development,
                location: "技术部",
                createdAt: today
            ),
            
            // Two weeks later Wednesday
            ScheduleItem(
                title: "投资人会议",
                description: "季度业绩汇报",
                startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 2, to: twoWeeksLater)!)!,
                endTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 2, to: twoWeeksLater)!)!,
                category: .presentation,
                location: "董事会议室",
                createdAt: today
            ),
            
            // Next month schedule
            ScheduleItem(
                title: "月度规划会议",
                description: "下月工作计划制定",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: nextMonth)!,
                endTime: calendar.date(bySettingHour: 11, minute: 30, second: 0, of: nextMonth)!,
                category: .planning,
                location: "大会议室",
                createdAt: today
            ),
            ScheduleItem(
                title: "产品发布会",
                description: "新版本正式发布",
                startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: nextMonth)!,
                endTime: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: nextMonth)!,
                category: .presentation,
                location: "发布厅",
                createdAt: today
            ),
            
            // Next month + 1 week
            ScheduleItem(
                title: "客户反馈收集会",
                description: "收集新版本用户反馈",
                startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 7, to: nextMonth)!)!,
                endTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 7, to: nextMonth)!)!,
                category: .review,
                location: "会议室A",
                createdAt: today
            ),
            ScheduleItem(
                title: "技术债务梳理",
                description: "清理技术债务计划",
                startTime: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 7, to: nextMonth)!)!,
                endTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 7, to: nextMonth)!)!,
                category: .development,
                location: "技术部",
                createdAt: today
            ),
            
            // Next month + 2 weeks
            ScheduleItem(
                title: "年度规划会议",
                description: "下年度战略规划讨论",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 14, to: nextMonth)!)!,
                endTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 14, to: nextMonth)!)!,
                category: .planning,
                location: "会议中心",
                createdAt: today
            )
        ]
    }()
    
    @State private var allTasks: [Task] = {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: today)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        return [
            // Today's deadlines
            Task(
                title: "Document Review",
                description: "Review the technical specification document",
                dueDate: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today)!,
                priority: .high,
                category: .documentation
            ),
            Task(
                title: "Team Meeting Prep",
                description: "Prepare slides for the weekly team meeting",
                dueDate: calendar.date(bySettingHour: 15, minute: 30, second: 0, of: today)!,
                priority: .medium,
                category: .meeting
            ),
            
            // Tomorrow's deadlines
            Task(
                title: "App Submission",
                description: "Submit the mobile app to the app store",
                dueDate: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: tomorrow)!,
                priority: .urgent,
                category: .development
            ),
            Task(
                title: "Design Review",
                description: "Complete UI/UX design review with stakeholders",
                dueDate: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: tomorrow)!,
                priority: .high,
                category: .design
            ),
            
            // Day after tomorrow
            Task(
                title: "Database Migration",
                description: "Migrate production database to new schema",
                dueDate: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: dayAfterTomorrow)!,
                priority: .high,
                category: .development
            ),
            
            // Next week
            Task(
                title: "Quarterly Presentation",
                description: "Present quarterly results to board of directors",
                dueDate: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: nextWeek)!,
                priority: .urgent,
                category: .presentation
            ),
            Task(
                title: "System Testing",
                description: "Complete integration testing for new features",
                dueDate: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: nextWeek)!,
                priority: .medium,
                category: .testing
            ),
            
            // Next month
            Task(
                title: "Project Milestone",
                description: "Complete Phase 2 of the development project",
                dueDate: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: nextMonth)!,
                priority: .high,
                category: .milestone
            ),
            
            // Completed tasks (various dates)
            Task(
                title: "Code Review",
                description: "Review pull requests from team members",
                dueDate: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: yesterday)!,
                completedAt: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: today)!,
                isCompleted: true,
                priority: .medium,
                category: .review
            ),
            Task(
                title: "Bug Fixes",
                description: "Fix critical bugs reported in production",
                dueDate: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: yesterday)!,
                completedAt: calendar.date(bySettingHour: 14, minute: 15, second: 0, of: today)!,
                isCompleted: true,
                priority: .urgent,
                category: .development
            ),
            Task(
                title: "Client Communication",
                description: "Send project update to client stakeholders",
                dueDate: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!,
                completedAt: calendar.date(bySettingHour: 8, minute: 45, second: 0, of: today)!,
                isCompleted: true,
                priority: .medium,
                category: .communication
            ),
            
            // Future tasks with various priorities
            Task(
                title: "Performance Optimization",
                description: "Optimize application performance and reduce load times",
                dueDate: calendar.date(byAdding: .day, value: 14, to: today)!,
                priority: .medium,
                category: .development
            ),
            Task(
                title: "Documentation Update",
                description: "Update API documentation with latest changes",
                dueDate: calendar.date(byAdding: .day, value: 21, to: today)!,
                priority: .low,
                category: .documentation
            ),
            Task(
                title: "Security Audit",
                description: "Conduct comprehensive security audit of the system",
                dueDate: calendar.date(byAdding: .day, value: 35, to: today)!,
                priority: .high,
                category: .testing
            )
        ]
    }()
    
    @State private var currentTime = Date()
    
    // Computed properties for filtered data based on selected date
    private var todaySchedule: [ScheduleItem] {
        let calendar = Calendar.current
        return allScheduleItems.filter { item in
            calendar.isDate(item.startTime, inSameDayAs: selectedDate)
        }
    }
    
    private var pendingDeadlines: [Task] {
        // Use selected date as the baseline instead of current date
        let calendar = Calendar.current
        let startOfSelectedDate = calendar.startOfDay(for: selectedDate)
        
        return allTasks
            .filter { task in
                !task.isCompleted && task.dueDate >= startOfSelectedDate
            }
            .sorted { task1, task2 in
                // Sort by due date (nearest first)
                return task1.dueDate < task2.dueDate
            }
    }
    
    private var todayCompletedTasks: [Task] {
        let calendar = Calendar.current
        return allTasks
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
                // Conditional Content based on selected tab
                if selectedTab == 0 {
                    // Home Tab - Dashboard
                    VStack(spacing: 0) {
                        // Simple Header
                        headerView
                        
                        // Main Content
                        HStack(spacing: 0) {
                            // Left Timeline (35% width)
                            timelineView
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemGray6).opacity(0.3))
                            
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
                            .background(Color(.systemBackground))
                        }
                    }
                } else if selectedTab == 1 {
                    // Projects Tab
                    ProjectOverviewView()
                } else {
                    // Placeholder for other tabs
                    VStack {
                        Spacer()
                        Text("即将推出")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("敬请期待更多功能")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                // Bottom Navigation Bar
                bottomNavigationBar
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showingDatePicker) {
            datePickerSheet
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
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
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
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    
                    Button("确定") {
                        showingDatePicker = false
                        // Data automatically updates through computed properties
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
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

// MARK: - Timeline View (Dynamic with Multi-hour Events)
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
                    .fill(isCurrentHour(hour) ? Color.blue : Color(.systemGray4))
                    .frame(width: isCurrentHour(hour) ? 8 : 6, height: isCurrentHour(hour) ? 8 : 6)
                
                if hour < 18 {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 1, height: 48)
                }
            }
            
            // Event content area
            VStack(alignment: .leading, spacing: 4) {
                ForEach(getEventsForHour(hour), id: \.id) { event in
                    scheduleEventView(event, currentHour: hour)
                }
                
                if getEventsForHour(hour).isEmpty {
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
    
    private func deadlineTaskRow(_ task: Task) -> some View {
        let urgencyColor = getUrgencyColor(for: task.dueDate)
        
        return HStack(spacing: 12) {
            // Completion checkbox
            Button(action: {
                // Toggle completion logic would go here
            }) {
                Image(systemName: "circle")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(task.category.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(urgencyColor.opacity(0.1))
                        .foregroundColor(urgencyColor)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(urgencyColor)
                            .frame(width: 6, height: 6)
                        
                        Text(formatAbsoluteDueTime(task.dueDate))
                            .font(.caption)
                            .foregroundColor(urgencyColor)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(urgencyColor.opacity(0.05))
        .cornerRadius(8)
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
        HStack(spacing: 12) {
            // Completion checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.green)
            
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
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.green.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Bottom Navigation Bar
extension DashboardView {
    private var bottomNavigationBar: some View {
        HStack {
            // Home
            bottomNavButton(
                icon: "house",
                title: "首页",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            Spacer()
            
            // Project
            bottomNavButton(
                icon: "folder",
                title: "项目",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            Spacer()
            
            // Add Button (Large Center)
            Button(action: {
                // Add new task/event action
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Spacer()
            
            // Team
            bottomNavButton(
                icon: "person.3",
                title: "团队",
                isSelected: selectedTab == 3,
                action: { selectedTab = 3 }
            )
            
            Spacer()
            
            // Me
            bottomNavButton(
                icon: "person.circle",
                title: "我的",
                isSelected: selectedTab == 4,
                action: { selectedTab = 4 }
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: -1)
        )
    }
    
    private func bottomNavButton(icon: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .secondary)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
        }
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
        let allPendingTimes = pendingDeadlines.map { $0.dueDate.timeIntervalSince(now) }
        
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
        case .meeting: return .blue
        case .review: return .green
        case .development: return .purple
        case .design: return .pink
        case .communication: return .orange
        case .presentation: return .red
        case .milestone: return .indigo
        case .planning: return .teal
        case .testing: return .cyan
        case .documentation: return .brown
        }
    }
    
    private func formatRelativeDueTime(_ date: Date) -> String {
        let now = Date()
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
