//
//  EditProfileView.swift
//  ppp
//
//  Created by Kiro on 9/22/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var userManager = UserDataManager.shared
    
    @State private var tempUserName: String = ""
    @State private var tempUserEmail: String = ""
    @State private var showingImagePicker = false
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 头像编辑区域
                    avatarSection
                    
                    // 个人信息编辑
                    personalInfoSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                    .disabled(tempUserName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            tempUserName = userManager.userName
            tempUserEmail = userManager.userEmail
        }
        .alert("保存成功", isPresented: $showingSaveAlert) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("个人资料已更新")
        }
    }
}

// MARK: - Avatar Section
extension EditProfileView {
    private var avatarSection: some View {
        VStack(spacing: 16) {
            // 当前头像
            Button(action: {
                showingImagePicker = true
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
                        .frame(width: 100, height: 100)
                    
                    Text(generateInitials(from: tempUserName))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // 编辑图标
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        )
                        .offset(x: 35, y: 35)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("点击更换头像")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Personal Info Section
extension EditProfileView {
    private var personalInfoSection: some View {
        VStack(spacing: 0) {
            // 姓名输入
            inputRow(
                title: "姓名",
                text: $tempUserName,
                placeholder: "请输入姓名",
                isFirst: true
            )
            
            // 邮箱输入
            inputRow(
                title: "邮箱",
                text: $tempUserEmail,
                placeholder: "请输入邮箱地址",
                keyboardType: .emailAddress,
                isLast: true
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
    
    private func inputRow(
        title: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        isFirst: Bool = false,
        isLast: Bool = false
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(width: 60, alignment: .leading)
                
                TextField(placeholder, text: text)
                    .font(.subheadline)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            if !isLast {
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 0.5)
                    .padding(.leading, 96)
            }
        }
    }
}

// MARK: - Helper Functions
extension EditProfileView {
    private func generateInitials(from name: String) -> String {
        let components = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        if components.isEmpty {
            return "?"
        } else if components.count == 1 {
            return String(components[0].prefix(2)).uppercased()
        } else {
            let firstInitial = String(components[0].prefix(1))
            let lastInitial = String(components[1].prefix(1))
            return (firstInitial + lastInitial).uppercased()
        }
    }
    
    private func saveProfile() {
        // 验证输入
        let trimmedName = tempUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = tempUserEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else { return }
        
        // 更新数据
        userManager.updateProfile(name: trimmedName, email: trimmedEmail)
        
        // 显示保存成功提示
        showingSaveAlert = true
    }
}

#Preview {
    EditProfileView()
}