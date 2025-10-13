import SwiftUI

struct OCREditorView: View {
    let ocrResult: OCRResult?
    @Binding var suggestedTitle: String
    @Binding var suggestedDescription: String
    let onApply: (String, String) -> Void
    let onCancel: () -> Void
    
    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with confidence indicator
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Original text section
                        originalTextSection
                        
                        // Smart analysis results
                        analysisResultsSection
                        
                        // Editable fields
                        editableFieldsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                setupInitialValues()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button("取消") {
                    onCancel()
                }
                .foregroundColor(.softTeal)
                
                Spacer()
                
                    Text("编辑任务内容")
                        .font(.headline)
                        .fontWeight(.semibold)
                
                Spacer()
                
                Button("应用") {
                    onApply(editedTitle, editedDescription)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(editedTitle.isEmpty ? Color.gray : Color.softTeal)
                )
                .disabled(editedTitle.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
        }
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    
    private var originalTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.softTeal)
                Text("原始识别文本")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if let result = ocrResult {
                Text(result.originalText)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.softTeal.opacity(0.05))
        )
    }
    
    private var analysisResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.softPink)
                Text("智能分析结果")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if let result = ocrResult {
                VStack(spacing: 12) {
                    // AI suggested title
                    VStack(alignment: .leading, spacing: 6) {
                                        Text("标题:")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                        
                        if !result.extractedInfo.title.isEmpty {
                            Text(result.extractedInfo.title)
                                .font(.body)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.softPink.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.softPink.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        } else {
                            Text("未识别到标题内容")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    // AI suggested description
                    VStack(alignment: .leading, spacing: 6) {
                                        Text("描述:")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                        
                        if !result.extractedInfo.description.isEmpty {
                            Text(result.extractedInfo.description)
                                .font(.body)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        } else {
                            Text("未识别到描述内容")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.softPink.opacity(0.05))
        )
    }
    
    private var editableFieldsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "pencil")
                    .foregroundColor(.green)
                Text("编辑确认")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Title editor
                VStack(alignment: .leading, spacing: 8) {
                    Text("任务标题 *")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $editedTitle)
                        .font(.body)
                        .frame(minHeight: 44)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(editedTitle.isEmpty ? Color.red.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    if editedTitle.isEmpty {
                        Text("标题不能为空")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Description editor
                VStack(alignment: .leading, spacing: 8) {
                    Text("任务描述")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $editedDescription)
                        .font(.body)
                        .frame(minHeight: 80)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                // Quick action buttons
                HStack(spacing: 12) {
                    Button("使用识别结果") {
                        if let result = ocrResult {
                            editedTitle = result.extractedInfo.title
                            editedDescription = result.extractedInfo.description
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.softPink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.softPink.opacity(0.1))
                    .cornerRadius(8)
                    
                    Button("使用原文") {
                        if let result = ocrResult {
                            let lines = result.originalText.components(separatedBy: .newlines)
                                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                            
                            if !lines.isEmpty {
                                editedTitle = lines.first ?? ""
                                editedDescription = lines.dropFirst().joined(separator: "\n")
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.softTeal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.softTeal.opacity(0.1))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button("清空") {
                        editedTitle = ""
                        editedDescription = ""
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.05))
        )
    }
    
    private func setupInitialValues() {
        if let result = ocrResult {
            editedTitle = result.extractedInfo.title.isEmpty ? suggestedTitle : result.extractedInfo.title
            editedDescription = result.extractedInfo.description.isEmpty ? suggestedDescription : result.extractedInfo.description
        } else {
            editedTitle = suggestedTitle
            editedDescription = suggestedDescription
        }
    }
}

#Preview {
    OCREditorView(
        ocrResult: OCRResult(originalText: "完成项目报告\n需要包含数据分析和结论\n截止日期：明天"),
        suggestedTitle: .constant("完成项目报告"),
        suggestedDescription: .constant("需要包含数据分析和结论"),
        onApply: { _, _ in },
        onCancel: { }
    )
}
