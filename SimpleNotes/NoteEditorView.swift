import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \Folder.name) private var folders: [Folder]

    private var existingNote: Note?
    @State private var title: String
    @State private var noteBody: String
    @State private var isPinned: Bool
    @State private var isFavorite: Bool
    @State private var selectedColorHex: String
    @State private var selectedFolder: Folder?
    @State private var showingFolderPicker: Bool = false
    @State private var showingDeleteConfirmation: Bool = false

    private let colorPalette = [
        "", // Default / No tint
        "00D2FF", // Cyan
        "9D4EDD", // Violet
        "FF477E", // Coral
        "00F5D4", // Teal
        "FFB703", // Gold
        "3A86FF", // Blue
        "FF006E"  // Magenta
    ]

    init(note: Note? = nil, defaultFolder: Folder? = nil) {
        self.existingNote = note
        _title = State(initialValue: note?.title ?? "")
        _noteBody = State(initialValue: note?.body ?? "")
        _isPinned = State(initialValue: note?.isPinned ?? false)
        _isFavorite = State(initialValue: note?.isFavorite ?? false)
        _selectedColorHex = State(initialValue: note?.colorHex ?? "")
        _selectedFolder = State(initialValue: note?.folder ?? defaultFolder)
    }

    var currentTint: Color? {
        if !selectedColorHex.isEmpty {
            return Color(hex: selectedColorHex)
        }
        return nil
    }

    var body: some View {
        ZStack {
            // Ambient Liquid Glass Background
            LiquidAmbientBackground()

            VStack(spacing: 0) {
                // Top Custom Glass Header Bar
                HStack(spacing: 12) {
                    Button {
                        saveIfNeeded()
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Notes")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .liquidGlass(cornerRadius: 14)
                    }

                    Spacer()

                    // Folder Pill Selector
                    Button {
                        showingFolderPicker = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: selectedFolder?.iconName ?? "folder")
                                .font(.system(size: 12))
                            Text(selectedFolder?.name ?? "No Folder")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .liquidGlass(cornerRadius: 14, tint: selectedFolder != nil ? Color(hex: selectedFolder!.colorHex) : nil)
                    }
                    .foregroundStyle(.primary)

                    // Pin toggle button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isPinned.toggle()
                        }
                    } label: {
                        Image(systemName: isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(isPinned ? Color(hex: "FFB703") : .secondary)
                            .padding(8)
                            .liquidGlass(cornerRadius: 12)
                    }

                    // Options menu (Favorite, Tint, Share, Delete)
                    Menu {
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Label(isFavorite ? "Unfavorite" : "Favorite", systemImage: isFavorite ? "heart.fill" : "heart")
                        }

                        if !title.isEmpty || !noteBody.isEmpty {
                            ShareLink(item: "\(title)\n\n\(noteBody)") {
                                Label("Share Note", systemImage: "square.and.arrow.up")
                            }
                        }

                        if existingNote != nil {
                            Divider()
                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete Note", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(8)
                            .liquidGlass(cornerRadius: 12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)

                // Scrollable Note Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title Input
                        TextField("Title", text: $title, axis: .vertical)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .liquidGlass(cornerRadius: 18, tint: currentTint, opacity: 0.6)

                        // Color Pill Picker Bar
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Text("Glow:")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 4)

                                ForEach(colorPalette, id: \.self) { hex in
                                    let isSelected = (selectedColorHex == hex)
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedColorHex = hex
                                        }
                                    } label: {
                                        ZStack {
                                            if hex.isEmpty {
                                                Circle()
                                                    .strokeBorder(Color.secondary.opacity(0.5), lineWidth: 1.5)
                                                    .frame(width: 24, height: 24)
                                                Image(systemName: "slash.circle")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(.secondary)
                                            } else {
                                                Circle()
                                                    .fill(Color(hex: hex))
                                                    .frame(width: 24, height: 24)
                                            }

                                            if isSelected {
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: 2)
                                                    .frame(width: 28, height: 28)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .liquidGlass(cornerRadius: 16, opacity: 0.5)
                        }

                        // Body TextEditor
                        ZStack(alignment: .topLeading) {
                            if noteBody.isEmpty {
                                Text("Start typing your thoughts, ideas, or markdown...")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(.secondary.opacity(0.7))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)
                            }

                            TextEditor(text: $noteBody)
                                .font(.system(size: 16, weight: .regular))
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(minHeight: 350)
                        }
                        .liquidGlass(cornerRadius: 22, tint: currentTint, opacity: 0.7)

                        // Bottom Metadata Bar
                        HStack {
                            let wordCount = noteBody.split(whereSeparator: \.isWhitespace).count
                            let charCount = noteBody.count

                            Text("\(wordCount) words · \(charCount) characters")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)

                            Spacer()

                            if let note = existingNote {
                                Text("Edited \(note.updatedAt, format: .dateTime.month().day().hour().minute())")
                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingFolderPicker) {
            folderSelectionSheet
        }
        .alert("Delete Note?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let note = existingNote {
                    modelContext.delete(note)
                }
                dismiss()
            }
        } message: {
            Text("This note will be permanently removed.")
        }
    }

    private var folderSelectionSheet: some View {
        NavigationStack {
            ZStack {
                LiquidAmbientBackground()

                VStack(spacing: 16) {
                    Text("Select Folder")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .padding(.top, 16)

                    List {
                        // None option
                        Button {
                            selectedFolder = nil
                            showingFolderPicker = false
                        } label: {
                            HStack {
                                Image(systemName: "tray")
                                    .foregroundStyle(.secondary)
                                Text("No Folder")
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedFolder == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color(hex: "00D2FF"))
                                }
                            }
                        }
                        .listRowBackground(Color.clear)

                        ForEach(folders) { folder in
                            Button {
                                selectedFolder = folder
                                showingFolderPicker = false
                            } label: {
                                HStack {
                                    Image(systemName: folder.iconName)
                                        .foregroundStyle(Color(hex: folder.colorHex))
                                    Text(folder.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selectedFolder?.id == folder.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color(hex: "00D2FF"))
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showingFolderPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func saveIfNeeded() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBody = noteBody.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty || !trimmedBody.isEmpty else {
            return
        }

        if let note = existingNote {
            note.title = title
            note.body = noteBody
            note.isPinned = isPinned
            note.isFavorite = isFavorite
            note.colorHex = selectedColorHex
            note.folder = selectedFolder
            note.updatedAt = .now
        } else {
            let newNote = Note(
                title: title,
                body: noteBody,
                isPinned: isPinned,
                isFavorite: isFavorite,
                colorHex: selectedColorHex,
                folder: selectedFolder
            )
            modelContext.insert(newNote)
        }
    }
}
