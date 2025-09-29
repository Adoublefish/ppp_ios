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
                    
                    if let estimatedHours = currentTask?.estimatedHours {
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
                    
                    // Quick time buttons
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach([0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0], id: \.self) { hours in
                            Button(action: {
                                actualHours = hours
                            }) {
                                VStack(spacing: 6) {
                                    Text(formatTime(hours))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text(getTimeLabel(hours))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    actualHours == hours ? 
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) : 
                                    LinearGradient(
                                        colors: [Color(.systemGray6)],
                                        startPoint: .center,
                                        endPoint: .center
                                    )
                                )
                                .foregroundColor(actualHours == hours ? .white : .primary)
                                .cornerRadius(16)
                                .shadow(
                                    color: actualHours == hours ? Color.blue.opacity(0.3) : Color.clear,
                                    radius: actualHours == hours ? 8 : 0,
                                    x: 0,
                                    y: 4
                                )
                            }
                            .scaleEffect(actualHours == hours ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: actualHours)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Efficiency indicator
                if let estimatedHours = currentTask?.estimatedHours, estimatedHours > 0 {
                    VStack(spacing: 8) {
                        Text("效率指标")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        let efficiency = actualHours / estimatedHours
                        HStack(spacing: 12) {
                            Image(systemName: efficiency <= 1.0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .font(.title2)
                                .foregroundColor(efficiency <= 1.0 ? .green : .orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(format: "%.0f%%", efficiency * 100))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(efficiency <= 1.0 ? .green : .orange)
                                
                                Text(efficiency <= 1.0 ? "按时完成" : "超出预期")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            (efficiency <= 1.0 ? Color.green : Color.orange).opacity(0.1)
                        )
                        .cornerRadius(12)
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