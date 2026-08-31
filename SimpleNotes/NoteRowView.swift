import SwiftUI

struct NoteRowView: View {
    let note: Note
    var isGrid: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    var noteTint: Color? {
        if !note.colorHex.isEmpty {
            return Color(hex: note.colorHex)
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Pinned icon + Folder Badge + Date
            HStack(spacing: 6) {
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: "FFB703"))
                        .padding(4)
                        .background {
                            Circle()
                                .fill(Color(hex: "FFB703").opacity(0.18))
                        }
                }

                if let folder = note.folder {
                    GlassBadge(
                        title: folder.name,
                        icon: folder.iconName,
                        tint: Color(hex: folder.colorHex)
                    )
                }

                Spacer()

                if note.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "FF477E"))
                }

                Text(note.updatedAt, style: .relative)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            // Note Title
            Text(note.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Note" : note.title)
                .font(.system(size: isGrid ? 16 : 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(isGrid ? 2 : 1)

            // Note Body Preview
            if !note.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(note.body)
                    .font(.system(size: isGrid ? 13 : 14, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(isGrid ? 4 : 2)
                    .lineSpacing(2)
            }

            if isGrid {
                Spacer(minLength: 4)
            }

            // Footer metadata
            HStack {
                let wordCount = note.body.split(separator: " ").count

                Text("\(wordCount) words")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(
            LiquidGlassModifier(
                cornerRadius: 18,
                tint: noteTint,
                opacity: colorScheme == .dark ? 0.75 : 0.85,
                glowRadius: note.isPinned ? 8 : 0
            )
        )
    }
}
