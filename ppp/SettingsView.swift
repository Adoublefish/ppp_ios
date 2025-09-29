//
//  SettingsView.swift
//  ppp
//
//  Created by Kiro on 9/22/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 设置状态
    @State private var notificationsEnabled = true
    @State private var calendarSyncEnabled = true
    @State private var aiFeatureEnabled = true
    @State private var darkModePreference = DarkModePreference.automatic
    @State private var selectedLanguage = Language.chinese
    @State private var cloudBackupEnabled = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("设置")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
            
            // Content
            List {
                // 通知设置
                notificationSection
                
                // 同步设置
                syncSection
                
                // 外观设置
                appearanceSection
                
                // AI功能设置
                aiSection
                
                // 数据与隐私
                dataPrivacySection
                
                // 关于应用
                aboutSection
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Notification Section
extension SettingsView {
    private var notificationSection: some View {
        Section {
            HStack {
                Label("推送通知", systemImage: "bell")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $notificationsEnabled)
            }
            
            if notificationsEnabled {
                NavigationLink(destination: NotificationDetailView()) {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("通知详细设置")
                                .font(.subheadline)
                            Text("任务提醒、截止日期等")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        } header: {
            Text("通知")
        } footer: {
            if !notificationsEnabled {
                Text("关闭后将不会收到任何推送通知")
            }
        }
    }
}

// MARK: - Sync Section
extension SettingsView {
    private var syncSection: some View {
        Section {
            HStack {
                Label("日历同步", systemImage: "calendar")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $calendarSyncEnabled)
            }
            
            if calendarSyncEnabled {
                NavigationLink(destination: CalendarSyncDetailView()) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.green)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("同步设置")
                                .font(.subheadline)
                            Text("选择要同步的日历")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            HStack {
                Label("云端备份", systemImage: "icloud")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $cloudBackupEnabled)
            }
        } header: {
            Text("同步与备份")
        } footer: {
            Text("开启后任务和项目数据将自动同步到云端")
        }
    }
}

// MARK: - Appearance Section
extension SettingsView {
    private var appearanceSection: some View {
        Section {
            NavigationLink(destination: AppearanceDetailView(darkModePreference: $darkModePreference)) {
                HStack {
                    Label("外观", systemImage: "paintbrush")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(darkModePreference.displayName)
                        .foregroundColor(.secondary)
                }
            }
            
            NavigationLink(destination: LanguageDetailView(selectedLanguage: $selectedLanguage)) {
                HStack {
                    Label("语言", systemImage: "globe")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(selectedLanguage.displayName)
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("个性化")
        }
    }
}

// MARK: - AI Section
extension SettingsView {
    private var aiSection: some View {
        Section {
            HStack {
                Label("AI功能", systemImage: "brain.head.profile")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $aiFeatureEnabled)
            }
            
            if aiFeatureEnabled {
                NavigationLink(destination: AISettingsDetailView()) {
                    HStack {
                        Image(systemName: "wand.and.rays")
                            .foregroundColor(.purple)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AI助手设置")
                                .font(.subheadline)
                            Text("智能建议、任务分解等")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        } header: {
            Text("智能功能")
        } footer: {
            Text("AI功能可以帮助您更高效地管理任务和项目")
        }
    }
}

// MARK: - Data Privacy Section
extension SettingsView {
    private var dataPrivacySection: some View {
        Section {
            NavigationLink(destination: PrivacyDetailView()) {
                Label("隐私政策", systemImage: "hand.raised")
                    .foregroundColor(.primary)
            }
            
            NavigationLink(destination: DataExportView()) {
                Label("导出数据", systemImage: "square.and.arrow.up")
                    .foregroundColor(.primary)
            }
            
            Button(action: clearCache) {
                HStack {
                    Label("清理缓存", systemImage: "trash")
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text("2.3 MB")
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("数据与隐私")
        }
    }
}

// MARK: - About Section
extension SettingsView {
    private var aboutSection: some View {
        Section {
            NavigationLink(destination: HelpCenterView()) {
                Label("帮助中心", systemImage: "questionmark.circle")
                    .foregroundColor(.primary)
            }
            
            NavigationLink(destination: ContactSupportView()) {
                Label("联系客服", systemImage: "message")
                    .foregroundColor(.primary)
            }
            
            Button(action: rateApp) {
                Label("评价应用", systemImage: "star")
                    .foregroundColor(.primary)
            }
            
            NavigationLink(destination: AboutAppView()) {
                Label("关于PPP", systemImage: "info.circle")
                    .foregroundColor(.primary)
            }
        } header: {
            Text("帮助与支持")
        }
    }
}

// MARK: - Helper Functions
extension SettingsView {
    private func clearCache() {
        // 实现清理缓存逻辑
        print("清理缓存")
    }
    
    private func rateApp() {
        // 实现应用评价逻辑
        print("评价应用")
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
}

enum Language: String, CaseIterable, CustomStringConvertible {
    case chinese = "zh-CN"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .chinese: return "简体中文"
        case .english: return "English"
        }
    }
    
    var description: String {
        return displayName
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

struct LanguageDetailView: View {
    @Binding var selectedLanguage: Language
    
    var body: some View {
        List {
            ForEach(Language.allCases, id: \.self) { language in
                Button(action: {
                    selectedLanguage = language
                }) {
                    HStack {
                        Text(language.displayName)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedLanguage == language {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("语言")
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