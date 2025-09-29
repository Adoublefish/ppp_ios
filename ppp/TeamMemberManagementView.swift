//
//  TeamMemberManagementView.swift
//  ppp
//
//  Created by Kiro on 8/5/25.
//

import SwiftUI
import Foundation

struct TeamMemberManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var showingAddMember = false
    @State private var editingMember: TeamMember?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Team Members List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(dataManager.getAllUsers()) { member in
                            TeamMemberRowView(
                                member: member,
                                onEdit: { editingMember = member },
                                onDelete: { dataManager.deleteTeamMember(member.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .sheet(isPresented: $showingAddMember) {
            AddTeamMemberView()
        }
        .sheet(item: $editingMember) { member in
            EditTeamMemberView(member: member)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("取消") {
                dismiss()
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            Text("团队成员管理")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                showingAddMember = true
            }) {
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8) // 大幅减少顶部距离
        .padding(.bottom, 8) // 减少底部距离
        .background(Color(.systemBackground))
    }
}

struct TeamMemberRowView: View {
    let member: TeamMember
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Image(systemName: member.avatar ?? "person.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            // Member Info
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let role = member.role {
                    Text(role)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions
            Menu {
                Button("编辑", action: onEdit)
                Button("删除", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AddTeamMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var name = ""
    @State private var role = ""
    @State private var selectedAvatar = "person.circle.fill"
    @State private var isOnline = false
    
    private let avatarOptions = [
        "person.circle.fill",
        "person.crop.circle.fill",
        "person.crop.square.fill",
        "person.2.circle.fill",
        "person.3.circle.fill"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Avatar Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("头像")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(avatarOptions, id: \.self) { avatar in
                                Button(action: {
                                    selectedAvatar = avatar
                                }) {
                                    Image(systemName: avatar)
                                        .font(.title)
                                        .foregroundColor(selectedAvatar == avatar ? .white : .blue)
                                        .frame(width: 50, height: 50)
                                        .background(selectedAvatar == avatar ? Color.blue : Color.blue.opacity(0.1))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(selectedAvatar == avatar ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                // Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("姓名")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("输入成员姓名", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Role Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("职位")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("输入职位（可选）", text: $role)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .navigationTitle("添加成员")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveTeamMember()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveTeamMember() {
        let newMember = TeamMember(
            name: name,
            avatar: selectedAvatar,
            role: role.isEmpty ? nil : role,
            isOnline: false // 默认设置为离线，不显示在线状态
        )
        dataManager.addTeamMember(newMember)
        dismiss()
    }
}

struct EditTeamMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    let member: TeamMember
    
    @State private var name: String
    @State private var role: String
    @State private var selectedAvatar: String
    @State private var isOnline: Bool
    
    private let avatarOptions = [
        "person.circle.fill",
        "person.crop.circle.fill",
        "person.crop.square.fill",
        "person.2.circle.fill",
        "person.3.circle.fill"
    ]
    
    init(member: TeamMember) {
        self.member = member
        self._name = State(initialValue: member.name)
        self._role = State(initialValue: member.role ?? "")
        self._selectedAvatar = State(initialValue: member.avatar ?? "person.circle.fill")
        self._isOnline = State(initialValue: member.isOnline)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Avatar Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("头像")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(avatarOptions, id: \.self) { avatar in
                                Button(action: {
                                    selectedAvatar = avatar
                                }) {
                                    Image(systemName: avatar)
                                        .font(.title)
                                        .foregroundColor(selectedAvatar == avatar ? .white : .blue)
                                        .frame(width: 50, height: 50)
                                        .background(selectedAvatar == avatar ? Color.blue : Color.blue.opacity(0.1))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(selectedAvatar == avatar ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                // Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("姓名")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("输入成员姓名", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Role Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("职位")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("输入职位（可选）", text: $role)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .navigationTitle("编辑成员")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        updateTeamMember()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func updateTeamMember() {
        let updatedMember = TeamMember(
            id: member.id,
            name: name,
            avatar: selectedAvatar,
            role: role.isEmpty ? nil : role,
            isOnline: false // 不显示在线状态
        )
        dataManager.updateTeamMember(updatedMember)
        dismiss()
    }
}

#Preview {
    TeamMemberManagementView()
}