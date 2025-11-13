//
//  ThemeManager.swift
//  ppp
//
//  简洁统一主题管理
//

import SwiftUI

// MARK: - 主题类型
enum AppTheme: String, CaseIterable {
    case standard = "standard"
    
    var displayName: String {
        return "标准"
    }
    
    var description: String {
        return "简约统一风格"
    }
    
    var icon: String {
        return "rectangle.portrait"
    }
}

// MARK: - 主题管理器
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .standard
    
    private init() {
        // 固定使用标准主题
        self.currentTheme = .standard
    }
}

// MARK: - 标准颜色定义（保留以支持现有组件）
extension Color {
    // 保留这些颜色定义以支持现有的UI组件
    static let clowCardPink = Color(red: 1.0, green: 0.75, blue: 0.8)
    static let clowCardGold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let clowCardPurple = Color(red: 0.72, green: 0.52, blue: 0.95)
    static let clowCardBlue = Color(red: 0.53, green: 0.81, blue: 0.92)
    static let clowCardGreen = Color(red: 0.68, green: 0.93, blue: 0.75)
}

