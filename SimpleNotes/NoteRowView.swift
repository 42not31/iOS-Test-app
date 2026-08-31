import SwiftUI

struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                }
                Text(note.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled" : note.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if note.isFavorite {
                    Image(systemName: "heart.fill").font(.caption).foregroundStyle(.pink)
                }
            }

            if !note.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(note.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 8) {
                if let folder = note.folder {
                    Label(folder.name, systemImage: folder.iconName)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color(hex: folder.colorHex))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background { Capsule().fill(Color(hex: folder.colorHex).opacity(0.12)) }
                }
                Text(note.updatedAt, style: .relative)
                    .font(.caption2).foregroundStyle(.secondary)
                Spacer()
                if !note.colorHex.isEmpty {
                    Circle().fill(Color(hex: note.colorHex)).frame(width: 8, height: 8)
                }
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }
}
