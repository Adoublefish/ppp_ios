//
//  ProfileView.swift
//  ppp
//
//  Created by Kiro on 9/22/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var userManager = UserDataManager.shared
    @State private var showingEditProfile = false
    @State private var showingSignOutAlert = false
    
    // 计算统计数据
    private var userStats: UserStatistics {
        userManager.getUserStatistics()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 用户资料卡片
                profileSection
                
                // 统计卡片
                statisticsSection
                
                // 设置选项
                settingsSection
                
                // 应用信息
                appInfoSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100) // 为底部导航栏留空间
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemGray6).opacity(0.3),
                    Color(.systemBackground)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .alert("退出登录", isPresented: $showingSignOutAlert) {
            Button("取消", role: .cancel) { }
            Button("退出", role: .destructive) {
                // 处理退出登录逻辑
                signOut()
            }
        } message: {
            Text("确定要退出当前账户吗？")
        }
    }
}

// MARK: - Profile Section
extension ProfileView {
    private var profileSection: some View {
        VStack(spacing: 16) {
            // 头像
            Button(action: {
                showingEditProfile = true
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text(userManager.userInitials)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 用户信息
            VStack(spacing: 4) {
                Text(userManager.userName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(userManager.userEmail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 编辑按钮
            Button(action: {
                showingEditProfile = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.caption)
                    Text("编辑资料")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

// MARK: - Statistics Section
extension ProfileView {
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("数据统计")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                statisticCard(
                    title: "任务",
                    value: "\(userStats.totalTasks)",
                    subtitle: "\(userStats.completedTasks)个已完成",
                    color: .blue,
                    icon: "checkmark.circle"
                )
                
                statisticCard(
                    title: "项目",
                    value: "\(userStats.totalProjects)",
                    subtitle: "进行中",
                    color: .green,
                    icon: "folder"
                )
                
                statisticCard(
                    title: "时长",
                    value: "\(userStats.totalHours)h",
                    subtitle: "总投入",
                    color: .orange,
                    icon: "clock"
                )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
    
    private func statisticCard(title: String, value: String, subtitle: String, color: Color, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.05))
        )
    }
}

// MARK: - Settings Section
extension ProfileView {
    private var settingsSection: some View {
        VStack(spacing: 24) {
            // 应用设置
            settingsGroup(title: "应用设置") {
                VStack(spacing: 0) {
                    // 通知设置
                    settingsToggleRow(
                        icon: "bell",
                        title: "推送通知",
                        subtitle: "接收任务提醒和更新",
                        isOn: $userManager.notificationsEnabled
                    )
                    
                    settingsDivider()
                    
                    // 日历同步
                    settingsToggleRow(
                        icon: "calendar",
                        title: "日历同步",
                        subtitle: "与系统日历同步任务",
                        isOn: $userManager.calendarSyncEnabled
                    )
                    
                    settingsDivider()
                    
                    // AI功能
                    settingsToggleRow(
                        icon: "brain.head.profile",
                        title: "AI功能",
                        subtitle: "智能任务建议和分解",
                        isOn: $userManager.aiFeatureEnabled
                    )
                    
                    settingsDivider()
                    
                    // 云端备份
                    settingsToggleRow(
                        icon: "icloud",
                        title: "云端备份",
                        subtitle: "自动备份数据到云端",
                        isOn: $userManager.cloudBackupEnabled
                    )
                }
            }
            
            // 外观设置
            settingsGroup(title: "外观设置") {
                VStack(spacing: 0) {
                    // 深色模式
                    settingsPickerRow(
                        icon: "moon",
                        title: "深色模式",
                        subtitle: userManager.darkModePreference.displayName,
                        options: DarkModePreference.allCases,
                        selection: $userManager.darkModePreference
                    )
                    
                    settingsDivider()
                    
                    // 语言设置
                    settingsPickerRow(
                        icon: "globe",
                        title: "语言",
                        subtitle: userManager.selectedLanguage.displayName,
                        options: Language.allCases,
                        selection: $userManager.selectedLanguage
                    )
                }
            }
            
            // 账户操作
            settingsGroup(title: "账户操作") {
                VStack(spacing: 0) {
                    // 编辑资料
                    settingsActionRow(
                        icon: "person.circle",
                        title: "编辑资料",
                        subtitle: "修改个人信息",
                        action: { showingEditProfile = true }
                    )
                    
                    settingsDivider()
                    
                    // 退出登录
                    settingsActionRow(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "退出登录",
                        subtitle: "退出当前账户",
                        isDestructive: true,
                        action: { showingSignOutAlert = true }
                    )
                }
            }
        }
    }
    
    private func settingsGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            content()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
        }
    }
    
    private func settingsToggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            // 内容
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 开关
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private func settingsPickerRow<T: CaseIterable & Hashable>(
        icon: String,
        title: String,
        subtitle: String,
        options: [T],
        selection: Binding<T>
    ) -> some View where T: RawRepresentable, T.RawValue == String, T: CustomStringConvertible {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            // 内容
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 选择器
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection.wrappedValue = option
                    }) {
                        HStack {
                            Text(option.description)
                            if selection.wrappedValue == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private func settingsActionRow(icon: String, title: String, subtitle: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 图标
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isDestructive ? .red : .blue)
                    .frame(width: 24, height: 24)
                
                // 内容
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isDestructive ? .red : .primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func settingsDivider() -> some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 0.5)
            .padding(.leading, 56)
    }
}

// MARK: - App Info Section
extension ProfileView {
    private var appInfoSection: some View {
        VStack(spacing: 16) {
            // 应用图标
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 4) {
                Text("PPP")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("版本 1.0.0 (Build 1)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("AI驱动的任务管理与团队协作平台")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

// MARK: - Helper Functions
extension ProfileView {
    private func signOut() {
        userManager.signOut()
        print("用户退出登录")
    }
}



#Preview {
    NavigationView {
        ProfileView()
    }
}