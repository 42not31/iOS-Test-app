import Foundation
import SwiftData

@Model
final class ChecklistItem {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var priority: Int // 0: Normal, 1: High, 2: Urgent
    var category: String
    
    init(
        title: String = "",
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        priority: Int = 0,
        category: String = "General"
    ) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = .now
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
    }
}
