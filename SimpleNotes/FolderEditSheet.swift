import SwiftUI
import SwiftData

struct FolderEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private var existingFolder: Folder?
    @State private var folderName: String
    @State private var selectedIcon: String
    @State private var selectedColorHex: String

    private let availableIcons = [
        "folder.fill", "briefcase.fill", "book.fill", "sparkles",
        "heart.fill", "star.fill", "lightbulb.fill", "tray.fill",
        "cart.fill", "graduationcap.fill", "music.note", "gamecontroller.fill",
        "airplane", "hammer.fill", "paintbrush.fill", "checkmark.seal.fill"
    ]

    private let availableColors = [
        "00D2FF", "9D4EDD", "FF477E", "00F5D4",
        "FFB703", "3A86FF", "FF5722", "4CAF50"
    ]

    init(folder: Folder? = nil) {
        self.existingFolder = folder
        _folderName = State(initialValue: folder?.name ?? "")
        _selectedIcon = State(initialValue: folder?.iconName ?? "folder.fill")
        _selectedColorHex = State(initialValue: folder?.colorHex ?? "00D2FF")
    }

    var selectedColor: Color { Color(hex: selectedColorHex) }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidAmbientBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        previewCard
                        nameCard
                        colorCard
                        iconCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle(existingFolder == nil ? "New Folder" : "Edit Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }
                        .disabled(folderName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var previewCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(selectedColor.opacity(0.25)).frame(width: 76, height: 76).blur(radius: 6)
                Circle().fill(selectedColor).frame(width: 60, height: 60)
                    .shadow(color: selectedColor.opacity(0.5), radius: 10, x: 0, y: 4)
                Image(systemName: selectedIcon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(folderName.trimmingCharacters(in: .whitespaces).isEmpty ? "Folder Preview" : folderName)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .liquidGlass(cornerRadius: 22, tint: selectedColor, opacity: 0.7)
    }

    private var nameCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FOLDER NAME")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            TextField("e.g. Work Projects, Journal, Study", text: $folderName)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding(12)
                .liquidGlass(cornerRadius: 14, opacity: 0.6)
        }
        .padding(16)
        .liquidGlass(cornerRadius: 20)
    }

    private var colorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FOLDER COLOR")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 12) {
                ForEach(availableColors, id: \.self) { hex in
                    colorCell(hex: hex)
                }
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 20)
    }

    private func colorCell(hex: String) -> some View {
        let isSelected = (selectedColorHex == hex)
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedColorHex = hex }
        } label: {
            ZStack {
                Circle().fill(Color(hex: hex)).frame(width: 44, height: 44)
                    .shadow(color: Color(hex: hex).opacity(0.35), radius: isSelected ? 8 : 2)
                if isSelected {
                    Circle().strokeBorder(Color.white, lineWidth: 3).frame(width: 50, height: 50)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var iconCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FOLDER ICON")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 12) {
                ForEach(availableIcons, id: \.self) { icon in
                    iconCell(icon: icon)
                }
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 20)
    }

    private func iconCell(icon: String) -> some View {
        let isSelected = (selectedIcon == icon)
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedIcon = icon }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? selectedColor : Color.clear)
                    .background { RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.ultraThinMaterial) }
                    .frame(height: 50)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.2), lineWidth: 1)
                    }
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
        }
        .buttonStyle(.plain)
    }

    private func save() {
        let trimmed = folderName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if let folder = existingFolder {
            folder.name = trimmed
            folder.iconName = selectedIcon
            folder.colorHex = selectedColorHex
        } else {
            let newFolder = Folder(name: trimmed, iconName: selectedIcon, colorHex: selectedColorHex)
            modelContext.insert(newFolder)
        }
    }
}
