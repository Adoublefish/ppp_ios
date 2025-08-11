//
//  CategoryManagementView.swift
//  ppp
//
//  Created by Kiro on 8/5/25.
//

import SwiftUI
import Foundation

struct CategoryManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var showingAddCategory = false
    @State private var editingCategory: CustomTaskCategory?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Categories List
                ScrollView {
                    VStack(spacing: 16) {
                        // Default Categories Section
                        defaultCategoriesSection
                        
                        // Custom Categories Section
                        customCategoriesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
        .sheet(item: $editingCategory) { category in
            EditCategoryView(category: category)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("取消") {
                dismiss()
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            Text("类别管理")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                showingAddCategory = true
            }) {
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
    }
    
    private var defaultCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("默认类别")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(TaskCategory.defaultCategories, id: \.self) { category in
                    DefaultCategoryRowView(category: category)
                }
            }
        }
    }
    
    private var customCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("自定义类别")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(dataManager.customCategories.count)个")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            
            if dataManager.customCategories.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "folder.badge.plus")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("暂无自定义类别")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("点击右上角 + 号添加")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color(.systemBackground))
                .cornerRadius(12)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(dataManager.customCategories) { category in
                        CustomCategoryRowView(
                            category: category,
                            onEdit: { editingCategory = category },
                            onDelete: { dataManager.deleteCustomCategory(category.id) }
                        )
                    }
                }
            }
        }
    }
}

struct DefaultCategoryRowView: View {
    let category: TaskCategory
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: categoryIcon(for: category))
                .font(.title3)
                .foregroundColor(categoryColor(for: category))
                .frame(width: 32, height: 32)
                .background(categoryColor(for: category).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("系统类别")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func categoryIcon(for category: TaskCategory) -> String {
        switch category {
        case .meeting: return "person.2"
        case .review: return "checkmark.circle"
        case .development: return "hammer"
        case .design: return "paintbrush"
        case .communication: return "message"
        case .presentation: return "presentation"
        case .milestone: return "flag"
        case .planning: return "calendar"
        case .testing: return "testtube.2"
        case .documentation: return "doc.text"
        case .custom: return "folder"
        }
    }
    
    private func categoryColor(for category: TaskCategory) -> Color {
        switch category {
        case .meeting: return Color.blue
        case .review: return Color.green
        case .development: return Color.orange
        case .design: return Color.purple
        case .communication: return Color.cyan
        case .presentation: return Color.red
        case .milestone: return Color.yellow
        case .planning: return Color.indigo
        case .testing: return Color.pink
        case .documentation: return Color.brown
        case .custom: return Color.gray
        }
    }
}

struct CustomCategoryRowView: View {
    let category: CustomTaskCategory
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundColor(Color(hex: category.color))
                .frame(width: 32, height: 32)
                .background(Color(hex: category.color).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("自定义类别")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Menu {
                Button("编辑", action: onEdit)
                Button("删除", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    @State private var name = ""
    @State private var selectedColor = "#3B82F6"
    @State private var selectedIcon = "folder"
    
    private let colorOptions = [
        "#3B82F6", "#10B981", "#F59E0B", "#EF4444",
        "#8B5CF6", "#EC4899", "#06B6D4", "#84CC16",
        "#F97316", "#6366F1", "#14B8A6", "#F43F5E"
    ]
    
    private let iconOptions = [
        "folder", "tag", "star", "heart", "bookmark",
        "flag", "bell", "gear", "lightbulb", "target",
        "trophy", "gift", "camera", "music.note", "gamecontroller"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("类别名称")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("输入类别名称", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Color Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("颜色")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: selectedColor)
                            }
                        }
                    }
                }
                
                // Icon Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("图标")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : Color(hex: selectedColor))
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? Color(hex: selectedColor) : Color(hex: selectedColor).opacity(0.1))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? Color(hex: selectedColor) : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
                
                // Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("预览")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: selectedIcon)
                            .font(.title3)
                            .foregroundColor(Color(hex: selectedColor))
                            .frame(width: 32, height: 32)
                            .background(Color(hex: selectedColor).opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name.isEmpty ? "类别名称" : name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("自定义类别")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: selectedColor).opacity(0.3), lineWidth: 1)
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .navigationTitle("添加类别")
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
                        saveCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        let newCategory = CustomTaskCategory(
            name: name,
            color: selectedColor,
            icon: selectedIcon
        )
        dataManager.addCustomCategory(newCategory)
        dismiss()
    }
}

struct EditCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    let category: CustomTaskCategory
    
    @State private var name: String
    @State private var selectedColor: String
    @State private var selectedIcon: String
    
    private let colorOptions = [
        "#3B82F6", "#10B981", "#F59E0B", "#EF4444",
        "#8B5CF6", "#EC4899", "#06B6D4", "#84CC16",
        "#F97316", "#6366F1", "#14B8A6", "#F43F5E"
    ]
    
    private let iconOptions = [
        "folder", "tag", "star", "heart", "bookmark",
        "flag", "bell", "gear", "lightbulb", "target",
        "trophy", "gift", "camera", "music.note", "gamecontroller"
    ]
    
    init(category: CustomTaskCategory) {
        self.category = category
        self._name = State(initialValue: category.name)
        self._selectedColor = State(initialValue: category.color)
        self._selectedIcon = State(initialValue: category.icon)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("类别名称")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("输入类别名称", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Color Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("颜色")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: selectedColor)
                            }
                        }
                    }
                }
                
                // Icon Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("图标")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : Color(hex: selectedColor))
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? Color(hex: selectedColor) : Color(hex: selectedColor).opacity(0.1))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? Color(hex: selectedColor) : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
                
                // Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("预览")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: selectedIcon)
                            .font(.title3)
                            .foregroundColor(Color(hex: selectedColor))
                            .frame(width: 32, height: 32)
                            .background(Color(hex: selectedColor).opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name.isEmpty ? "类别名称" : name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("自定义类别")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: selectedColor).opacity(0.3), lineWidth: 1)
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .navigationTitle("编辑类别")
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
                        updateCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func updateCategory() {
        let updatedCategory = CustomTaskCategory(
            id: category.id,
            name: name,
            color: selectedColor,
            icon: selectedIcon,
            createdAt: category.createdAt
        )
        dataManager.updateCustomCategory(updatedCategory)
        dismiss()
    }
}



#Preview {
    CategoryManagementView()
}