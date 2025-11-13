//
//  TaskTimeInputSheet.swift
//  ppp
//
//  Created by Kiro on 2025-01-22.
//

import SwiftUI

struct TaskTimeInputSheet: View {
    let taskId: UUID
    @State private var actualHours: Double
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = TaskDataManager.shared
    
    // Get current task from data manager
    private var currentTask: Task? {
        dataManager.allTasks.first { $0.id == taskId }
    }
    
    init(task: Task) {
        self.taskId = task.id
        self._actualHours = State(initialValue: task.actualHours ?? 0.0)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Task info
                VStack(spacing: 12) {
                    Text(currentTask?.title ?? "任务")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    if currentTask?.estimatedHours != nil {
                        Text("预估时间: \(currentTask?.formattedEstimatedTime ?? "N/A")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                
                // Time input section
                VStack(spacing: 16) {
                    Text("实际用时")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    // Time stepper
                    HStack {
                        Button(action: {
                            if actualHours > 0.25 {
                                actualHours -= 0.25
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(actualHours > 0.25 ? .blue : .gray)
                        }
                        .disabled(actualHours <= 0.25)
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text(formatTime(actualHours))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("实际用时")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if actualHours < 24 {
                                actualHours += 0.25
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(actualHours < 24 ? .blue : .gray)
                        }
                        .disabled(actualHours >= 24)
                    }
                    .padding(.horizontal, 20)
                    

                }
                

                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("取消") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .softButton(color: .secondaryAccent)
                    
                    Button("保存") {
                        if let task = currentTask {
                            dataManager.updateTaskActualHours(task, actualHours: actualHours)
                        }
                        dismiss()
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .softButton(color: .primaryAccent)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.backgroundPrimary.opacity(0.3),
                        Color.backgroundSecondary
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("记录用时")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func formatTime(_ hours: Double) -> String {
        if hours >= 1 {
            return String(format: "%.1fh", hours)
        } else {
            let minutes = Int(hours * 60)
            return "\(minutes)m"
        }
    }
    
    private func getTimeLabel(_ hours: Double) -> String {
        switch hours {
        case 0.25: return "15分钟"
        case 0.5: return "半小时"
        case 1.0: return "1小时"
        case 1.5: return "1.5小时"
        case 2.0: return "2小时"
        case 3.0: return "3小时"
        case 4.0: return "半天"
        case 6.0: return "大半天"
        default: return "自定义"
        }
    }
}

// MARK: - Preview
struct TaskTimeInputSheet_Previews: PreviewProvider {
    static var previews: some View {
        TaskTimeInputSheet(
            task: Task(
                title: "示例任务",
                description: "这是一个示例任务",
                priority: .medium,
                category: .development,
                estimatedHours: 2.0
            )
        )
    }
}