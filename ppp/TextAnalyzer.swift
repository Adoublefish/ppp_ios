import Foundation

struct ExtractedTaskInfo {
    let title: String
    let description: String
    let confidence: Double // 0.0 - 1.0
}

class TextAnalyzer {
    
    static func analyzeOCRText(_ text: String) -> ExtractedTaskInfo {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard !lines.isEmpty else {
            return ExtractedTaskInfo(title: "", description: "", confidence: 0.0)
        }
        
        // 如果只有一行，优先作为标题
        if lines.count == 1 {
            let line = lines[0]
            if line.count <= 50 {
                return ExtractedTaskInfo(title: line, description: "", confidence: 0.8)
            } else {
                // 长文本截取前50字符作为标题，剩余作为描述
                let title = String(line.prefix(50)).trimmingCharacters(in: .whitespaces)
                let description = line.count > 50 ? String(line.dropFirst(50)).trimmingCharacters(in: .whitespaces) : ""
                return ExtractedTaskInfo(title: title, description: description, confidence: 0.7)
            }
        }
        
        // 多行文本分析
        var title = ""
        var description = ""
        var confidence = 0.6
        
        // 寻找最可能的标题行
        let firstLine = lines[0]
        let titleCandidate = findBestTitleCandidate(lines)
        
        if let bestTitle = titleCandidate {
            title = bestTitle.title
            
            // 移除标题行，剩余作为描述
            var descriptionLines = lines
            if let titleIndex = lines.firstIndex(of: bestTitle.title) {
                descriptionLines.remove(at: titleIndex)
                confidence = bestTitle.confidence
            }
            
            description = descriptionLines.joined(separator: "\n")
        } else {
            // 默认策略：第一行作为标题，其余作为描述
            title = firstLine.count <= 50 ? firstLine : String(firstLine.prefix(50))
            let remainingLines = Array(lines.dropFirst())
            description = remainingLines.joined(separator: "\n")
            
            // 如果第一行太长，将剩余部分加入描述
            if firstLine.count > 50 {
                let remainingFirstLine = String(firstLine.dropFirst(50)).trimmingCharacters(in: .whitespaces)
                if !remainingFirstLine.isEmpty {
                    description = remainingFirstLine + (description.isEmpty ? "" : "\n" + description)
                }
            }
        }
        
        return ExtractedTaskInfo(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            confidence: confidence
        )
    }
    
    private static func findBestTitleCandidate(_ lines: [String]) -> (title: String, confidence: Double)? {
        var bestCandidate: (title: String, confidence: Double)?
        
        for (index, line) in lines.enumerated() {
            let score = calculateTitleScore(line, position: index, totalLines: lines.count)
            
            if let current = bestCandidate {
                if score > current.confidence {
                    bestCandidate = (title: line, confidence: score)
                }
            } else {
                bestCandidate = (title: line, confidence: score)
            }
        }
        
        // 只有当置信度足够高时才返回
        if let candidate = bestCandidate, candidate.confidence > 0.6 {
            return candidate
        }
        
        return nil
    }
    
    private static func calculateTitleScore(_ line: String, position: Int, totalLines: Int) -> Double {
        var score = 0.0
        
        // 位置权重：前几行更可能是标题
        if position == 0 {
            score += 0.3
        } else if position == 1 {
            score += 0.2
        } else if position == 2 {
            score += 0.1
        }
        
        // 长度权重：标题通常不会太长
        let length = line.count
        if length >= 5 && length <= 30 {
            score += 0.3
        } else if length <= 50 {
            score += 0.2
        } else if length > 80 {
            score -= 0.2 // 太长的行不太可能是标题
        }
        
        // 内容特征分析
        score += analyzeContentFeatures(line)
        
        // 标点符号分析
        score += analyzePunctuation(line)
        
        return min(1.0, max(0.0, score))
    }
    
    private static func analyzeContentFeatures(_ line: String) -> Double {
        var score = 0.0
        
        // 常见标题关键词
        let titleKeywords = [
            "任务", "计划", "目标", "项目", "会议", "工作", "学习", "完成", "处理", "准备",
            "安排", "联系", "讨论", "制作", "设计", "开发", "测试", "修复", "优化", "更新",
            "Task", "Plan", "Goal", "Project", "Meeting", "Work", "Study", "Complete", "Process", "Prepare"
        ]
        
        for keyword in titleKeywords {
            if line.contains(keyword) {
                score += 0.1
                break
            }
        }
        
        // 动词开头的句子更可能是任务标题
        let actionWords = [
            "完成", "制作", "准备", "安排", "联系", "处理", "学习", "开发", "设计", "修复", "更新", "优化",
            "Complete", "Make", "Prepare", "Arrange", "Contact", "Process", "Study", "Develop", "Design", "Fix", "Update", "Optimize"
        ]
        
        for action in actionWords {
            if line.hasPrefix(action) || line.hasPrefix(action.lowercased()) {
                score += 0.15
                break
            }
        }
        
        return score
    }
    
    private static func analyzePunctuation(_ line: String) -> Double {
        var score = 0.0
        
        // 标题通常不以句号结尾
        if !line.hasSuffix("。") && !line.hasSuffix(".") {
            score += 0.1
        }
        
        // 如果包含问号或感叹号，可能是标题
        if line.contains("?") || line.contains("？") || line.contains("!") || line.contains("！") {
            score += 0.1
        }
        
        // 如果包含冒号，前半部分可能是标题
        if line.contains(":") || line.contains("：") {
            score += 0.05
        }
        
        // 避免过多标点符号的行作为标题
        let punctuationCount = line.filter { ",.;:!?。，；：！？".contains($0) }.count
        if punctuationCount > 3 {
            score -= 0.1
        }
        
        return score
    }
}

// 用于UI显示的结构
struct OCRResult {
    let originalText: String
    let extractedInfo: ExtractedTaskInfo
    let timestamp: Date
    
    init(originalText: String) {
        self.originalText = originalText
        self.extractedInfo = TextAnalyzer.analyzeOCRText(originalText)
        self.timestamp = Date()
    }
}
