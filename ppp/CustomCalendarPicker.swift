//
//  CustomCalendarPicker.swift
//  ppp
//
//  简化的iOS原生日历选择器
//

import SwiftUI

struct CustomCalendarPicker: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    var includeTime: Bool = true  // 是否包含时间选择
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if includeTime {
                    // 日期和时间选择器
                    DatePicker(
                        "选择日期和时间",
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                } else {
                    // 仅日期选择器
                    DatePicker(
                        "选择日期",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                }
                
                // 确认按钮
                Button(action: {
                    dismiss()
                }) {
                    Text("确认")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle(includeTime ? "选择日期和时间" : "选择日期")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 预览
struct CustomCalendarPicker_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.systemGray5)
                .ignoresSafeArea()
            
            CustomCalendarPicker(selectedDate: .constant(Date()))
        }
    }
}

