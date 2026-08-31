import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date

    init(title: String = "", body: String = "") {
        self.id = UUID()
        self.title = title
        self.body = body
        self.createdAt = .now
        self.updatedAt = .now
    }
}
