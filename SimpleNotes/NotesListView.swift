import SwiftUI
import SwiftData

struct NotesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]
    @Query(sort: \Folder.name) private var folders: [Folder]

    @State private var searchText: String = ""
    @State private var isGridView: Bool = false
    @State private var selectedFilterFolderId: UUID? = nil
    @State private var filterFavoritesOnly: Bool = false
    @State private var showingNewNoteSheet: Bool = false

    private var filteredNotes: [Note] {
        allNotes.filter { note in
            let matchesSearch = searchText.isEmpty ||
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.body.localizedCaseInsensitiveContains(searchText)

            let matchesFolder = (selectedFilterFolderId == nil) || (note.folder?.id == selectedFilterFolderId)
            let matchesFavorite = !filterFavoritesOnly || note.isFavorite

            return matchesSearch && matchesFolder && matchesFavorite
        }
    }

    private var pinnedNotes: [Note] {
        filteredNotes.filter { $0.isPinned }
    }

    private var otherNotes: [Note] {
        filteredNotes.filter { !$0.isPinned }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidAmbientBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Top Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("SimpleNotes")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)

                                Text("\(allNotes.count) notes · \(Date.now.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            // Grid / List Toggle Button
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    isGridView.toggle()
                                }
                            } label: {
                                Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .padding(10)
                                    .liquidGlass(cornerRadius: 14)
                            }

                            // Quick New Note Button
                            Button {
                                showingNewNoteSheet = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "00D2FF"), Color(hex: "3A86FF")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: Color(hex: "00D2FF").opacity(0.4), radius: 8, x: 0, y: 3)
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                        // Search Bar
                        GlassSearchBar(text: $searchText, placeholder: "Search notes...")
                            .padding(.horizontal, 16)

                        // Folder Filter Pills Bar
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // All Filter
                                filterPill(title: "All Notes", icon: "square.stack.fill", isSelected: selectedFilterFolderId == nil && !filterFavoritesOnly) {
                                    selectedFilterFolderId = nil
                                    filterFavoritesOnly = false
                                }

                                // Favorites Filter
                                filterPill(title: "Favorites", icon: "heart.fill", isSelected: filterFavoritesOnly) {
                                    filterFavoritesOnly.toggle()
                                    selectedFilterFolderId = nil
                                }

                                // Folder Pills
                                ForEach(folders) { folder in
                                    filterPill(
                                        title: folder.name,
                                        icon: folder.iconName,
                                        isSelected: selectedFilterFolderId == folder.id,
                                        tint: Color(hex: folder.colorHex)
                                    ) {
                                        if selectedFilterFolderId == folder.id {
                                            selectedFilterFolderId = nil
                                        } else {
                                            selectedFilterFolderId = folder.id
                                            filterFavoritesOnly = false
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Content section
                        if filteredNotes.isEmpty {
                            emptyStateView
                                .padding(.top, 40)
                                .padding(.horizontal, 16)
                        } else {
                            // Pinned Notes Section
                            if !pinnedNotes.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "pin.fill")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(Color(hex: "FFB703"))
                                        Text("PINNED")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 16)

                                    renderNotesContainer(notes: pinnedNotes)
                                }
                            }

                            // Regular / Other Notes Section
                            if !otherNotes.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    if !pinnedNotes.isEmpty {
                                        Text("OTHER NOTES")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 16)
                                    }

                                    renderNotesContainer(notes: otherNotes)
                                }
                            }
                        }

                        // Bottom spacing for floating navbar
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 6)
                }
            }
            .navigationDestination(for: Note.self) { note in
                NoteEditorView(note: note)
            }
            .sheet(isPresented: $showingNewNoteSheet) {
                NoteEditorView(defaultFolder: folders.first(where: { $0.id == selectedFilterFolderId }))
            }
        }
    }

    // MARK: - Notes Container (Grid vs List)
    @ViewBuilder
    private func renderNotesContainer(notes: [Note]) -> some View {
        if isGridView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(notes) { note in
                    NavigationLink(value: note) {
                        NoteRowView(note: note, isGrid: true)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        noteContextMenu(note: note)
                    }
                }
            }
            .padding(.horizontal, 16)
        } else {
            LazyVStack(spacing: 10) {
                ForEach(notes) { note in
                    NavigationLink(value: note) {
                        NoteRowView(note: note, isGrid: false)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        noteContextMenu(note: note)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Context Menu
    @ViewBuilder
    private func noteContextMenu(note: Note) -> some View {
        Button {
            note.isPinned.toggle()
        } label: {
            Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
        }

        Button {
            note.isFavorite.toggle()
        } label: {
            Label(note.isFavorite ? "Unfavorite" : "Favorite", systemImage: note.isFavorite ? "heart.slash" : "heart")
        }

        Divider()

        Button(role: .destructive) {
            withAnimation {
                modelContext.delete(note)
            }
        } label: {
            Label("Delete Note", systemImage: "trash")
        }
    }

    // MARK: - Filter Pill Builder
    private func filterPill(title: String, icon: String, isSelected: Bool, tint: Color? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    (tint ?? Color(hex: "00D2FF")).opacity(0.85),
                                    Color(hex: "3A86FF").opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: (tint ?? Color(hex: "00D2FF")).opacity(0.3), radius: 6, x: 0, y: 2)
                } else {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
                }
            }
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "00D2FF").opacity(0.25), Color(hex: "9D4EDD").opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .blur(radius: 8)

                Image(systemName: searchText.isEmpty ? "note.text.badge.plus" : "magnifyingglass")
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(Color(hex: "00D2FF"))
            }

            VStack(spacing: 6) {
                Text(searchText.isEmpty ? "No Notes Yet" : "No Matching Notes")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(searchText.isEmpty ? "Tap the + button to create your first liquid glass note." : "Try searching for a different keyword.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if searchText.isEmpty {
                Button {
                    showingNewNoteSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Create First Note")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "00D2FF"), Color(hex: "3A86FF")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "00D2FF").opacity(0.4), radius: 10, x: 0, y: 4)
                    }
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .liquidGlass(cornerRadius: 24, opacity: 0.5)
    }
}
