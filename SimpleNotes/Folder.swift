import Foundation
import SwiftData

@Model
final class Folder {
    var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var createdAt: Date
    
    @Relationship(deleteRule: .nullify)
    var notes: [Note]?
    
    init(
        name: String = "New Folder",
        iconName: String = "folder.fill",
        colorHex: String = "0A84FF"
    ) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdAt = .now
        self.notes = []
    }
}
