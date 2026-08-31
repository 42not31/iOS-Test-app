import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    var isFavorite: Bool
    var colorHex: String
    
    @Relationship(inverse: \Folder.notes)
    var folder: Folder?

    init(
        title: String = "",
        body: String = "",
        isPinned: Bool = false,
        isFavorite: Bool = false,
        colorHex: String = "",
        folder: Folder? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.createdAt = .now
        self.updatedAt = .now
        self.isPinned = isPinned
        self.isFavorite = isFavorite
        self.colorHex = colorHex
        self.folder = folder
    }
}
