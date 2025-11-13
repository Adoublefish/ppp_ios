//
//  SettingsView.swift
//  ppp
//
//  Created by Kiro on 9/22/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var userManager = UserDataManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        
                        profileCard
                        
                        statsCard
                        
                        settingsSection(title: "通知") {
                            settingsCard {
                                notificationToggleRow
                                settingsDivider
                                notificationDetailRow
                            }
                        }
                        
                        settingsSection(title: "同步与备份") {
                            settingsCard {
                                calendarSyncToggleRow
                                settingsDivider
                                calendarSyncDetailRow
                                settingsDivider
                                cloudBackupToggleRow
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
        }
    }
}

// MARK: - Header & Profile
extension SettingsView {
    private var headerSection: some View {
        VStack(spacing: 0) {
            Text("设置")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 16)
                .padding(.bottom, 12)
            
            Divider()
                .frame(height: 1)
                .background(Color(.systemGray4))
        }
        .frame(maxWidth: .infinity)
        .background(
            Color(.systemBackground)
                .ignoresSafeArea(edges: .top)
        )
        .padding(.horizontal, -20)
    }
    
    private var profileCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.46, green: 0.61, blue: 0.99),
                                     Color(red: 0.53, green: 0.37, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 68, height: 68)
                
                Text(userManager.userInitials)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(userManager.userName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(userManager.userEmail)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("Member since March 2024")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 12, x: 0, y: 6)
        )
    }
    
    private var statsCard: some View {
        let stats = userManager.getUserStatistics()
        
        return HStack(spacing: 0) {
            statItem(value: "\(stats.completedTasks)", label: "Tasks Completed", color: Color(red: 0.10, green: 0.47, blue: 1.0))
            
            statDivider
            
            statItem(value: "\(stats.totalProjects)", label: "Active Projects", color: Color(red: 0.10, green: 0.72, blue: 0.38))
            
            statDivider
            
            statItem(value: "\(stats.totalHours)h", label: "Time Logged", color: Color(red: 1.0, green: 0.60, blue: 0.07))
        }
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 12, x: 0, y: 6)
        )
    }
    
    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var statDivider: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .frame(width: 1, height: 48)
    }
}

// MARK: - Settings Sections
extension SettingsView {
    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
            content()
        }
    }
    
    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
    
    private var notificationToggleRow: some View {
        toggleRow(
            title: "推送通知",
            subtitle: nil,
            systemImage: "bell",
            tint: Color(red: 0.10, green: 0.47, blue: 1.0),
            isOn: notificationsBinding
        )
    }
    
    private var notificationDetailRow: some View {
        navigationRow(
            title: "通知详细设置",
            subtitle: "任务提醒、截止日期等",
            systemImage: "bell.badge",
            tint: Color.orange
        ) {
            NotificationDetailView()
        }
    }
    
    private var calendarSyncToggleRow: some View {
        toggleRow(
            title: "日历同步",
            subtitle: nil,
            systemImage: "calendar",
            tint: Color(red: 0.19, green: 0.60, blue: 1.0),
            isOn: calendarSyncBinding
        )
    }
    
    private var calendarSyncDetailRow: some View {
        navigationRow(
            title: "同步设置",
            subtitle: "选择要同步的日历",
            systemImage: "arrow.triangle.2.circlepath",
            tint: Color(red: 0.22, green: 0.68, blue: 0.76)
        ) {
            CalendarSyncDetailView()
        }
    }
    
    private var cloudBackupToggleRow: some View {
        toggleRow(
            title: "云端备份",
            subtitle: "开启后任务和项目数据将自动同步到云端",
            systemImage: "icloud",
            tint: Color(red: 0.80, green: 0.82, blue: 0.90),
            isOn: cloudBackupBinding
        )
    }
    
    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { userManager.notificationsEnabled },
            set: { userManager.notificationsEnabled = $0 }
        )
    }
    
    private var calendarSyncBinding: Binding<Bool> {
        Binding(
            get: { userManager.calendarSyncEnabled },
            set: { userManager.calendarSyncEnabled = $0 }
        )
    }
    
    private var cloudBackupBinding: Binding<Bool> {
        Binding(
            get: { userManager.cloudBackupEnabled },
            set: { userManager.cloudBackupEnabled = $0 }
        )
    }
    
    private var settingsDivider: some View {
        Divider()
            .padding(.vertical, 8)
            .padding(.leading, 58)
    }
    
    private func settingsIcon(systemImage: String, tint: Color) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(tint == Color(red: 0.80, green: 0.82, blue: 0.90) ? Color(red: 0.36, green: 0.41, blue: 0.53) : tint)
            .frame(width: 42, height: 42)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(tint == Color(red: 0.80, green: 0.82, blue: 0.90) ? 0.4 : 0.15))
            )
    }
    
    private func toggleRow(title: String, subtitle: String?, systemImage: String, tint: Color, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            rowText(title: title, subtitle: subtitle, systemImage: systemImage, tint: tint)
        }
        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.10, green: 0.47, blue: 1.0)))
        .padding(.vertical, 4)
    }
    
    private func navigationRow<Destination: View>(title: String, subtitle: String?, systemImage: String, tint: Color, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 16) {
                settingsIcon(systemImage: systemImage, tint: tint)
                
                VStack(alignment: .leading, spacing: subtitle == nil ? 0 : 4) {
                    Text(title)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
    
    private func rowText(title: String, subtitle: String?, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 16) {
            settingsIcon(systemImage: systemImage, tint: tint)
            
            VStack(alignment: .leading, spacing: subtitle == nil ? 0 : 4) {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Supporting Types
enum DarkModePreference: String, CaseIterable, CustomStringConvertible {
    case light = "light"
    case dark = "dark"
    case automatic = "automatic"
    
    var displayName: String {
        switch self {
        case .light: return "浅色"
        case .dark: return "深色"
        case .automatic: return "跟随系统"
        }
    }
    
    var description: String {
        return displayName
    }
    
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .automatic: return nil
        }
    }
}

// MARK: - Placeholder Detail Views
struct NotificationDetailView: View {
    var body: some View {
        List {
            Section {
                Toggle("任务提醒", isOn: .constant(true))
                Toggle("截止日期提醒", isOn: .constant(true))
                Toggle("团队消息", isOn: .constant(true))
            } header: {
                Text("通知类型")
            }
            
            Section {
                Picker("提醒时间", selection: .constant(0)) {
                    Text("不提醒").tag(0)
                    Text("准时").tag(1)
                    Text("提前5分钟").tag(2)
                    Text("提前15分钟").tag(3)
                    Text("提前30分钟").tag(4)
                    Text("提前1小时").tag(5)
                }
            } header: {
                Text("默认提醒时间")
            }
        }
        .navigationTitle("通知设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CalendarSyncDetailView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.red)
                    Text("系统日历")
                    Spacer()
                    Toggle("", isOn: .constant(true))
                }
            } header: {
                Text("可用日历")
            } footer: {
                Text("选择要同步PPP任务的日历")
            }
        }
        .navigationTitle("日历同步")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppearanceDetailView: View {
    @Binding var darkModePreference: DarkModePreference
    
    var body: some View {
        List {
            ForEach(DarkModePreference.allCases, id: \.self) { preference in
                Button(action: {
                    darkModePreference = preference
                }) {
                    HStack {
                        Text(preference.displayName)
                            .foregroundColor(.primary)
                        Spacer()
                        if darkModePreference == preference {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("外观")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AISettingsDetailView: View {
    var body: some View {
        List {
            Section {
                Toggle("智能任务建议", isOn: .constant(true))
                Toggle("自动任务分解", isOn: .constant(true))
                Toggle("智能时间安排", isOn: .constant(false))
            } header: {
                Text("AI功能")
            }
        }
        .navigationTitle("AI设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("隐私政策")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("我们重视您的隐私，承诺保护您的个人信息安全...")
                    .font(.body)
                
                // 更多隐私政策内容
            }
            .padding()
        }
        .navigationTitle("隐私政策")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataExportView: View {
    var body: some View {
        List {
            Section {
                Button("导出所有数据") {
                    // 导出逻辑
                }
                Button("导出任务数据") {
                    // 导出任务
                }
                Button("导出项目数据") {
                    // 导出项目
                }
            } header: {
                Text("选择导出内容")
            } footer: {
                Text("数据将以JSON格式导出")
            }
        }
        .navigationTitle("导出数据")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpCenterView: View {
    var body: some View {
        List {
            Section("常见问题") {
                NavigationLink("如何创建任务？", destination: Text("帮助内容"))
                NavigationLink("如何使用AI功能？", destination: Text("帮助内容"))
                NavigationLink("如何邀请团队成员？", destination: Text("帮助内容"))
            }
        }
        .navigationTitle("帮助中心")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContactSupportView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("联系客服")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("如果您遇到问题或有任何建议，请联系我们")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("发送邮件") {
                // 发送邮件逻辑
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .navigationTitle("联系客服")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutAppView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 应用图标
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                
                VStack(spacing: 8) {
                    Text("PPP")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("版本 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("AI驱动的任务管理与团队协作平台，让效率如水般流畅。")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("功能特色：")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    FeatureRow(icon: "camera", title: "智能OCR", description: "拍照识别任务内容")
                    FeatureRow(icon: "brain.head.profile", title: "AI助手", description: "智能任务分解与建议")
                    FeatureRow(icon: "calendar", title: "日历同步", description: "与系统日历无缝集成")
                    FeatureRow(icon: "person.3", title: "团队协作", description: "高效的团队项目管理")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("关于PPP")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}


#Preview {
    SettingsView()
}
