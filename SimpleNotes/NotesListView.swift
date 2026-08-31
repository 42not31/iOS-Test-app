import SwiftUI
import SwiftData

struct NotesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]
    @Query(sort: \Folder.name) private var folders: [Folder]

    @State private var searchText = ""
    @State private var selectedFolder: Folder?
    @State private var showingNewNote = false
    @State private var showingFavoritesOnly = false

    private var filteredNotes: [Note] {
        allNotes.filter { note in
            let mSearch = searchText.isEmpty || note.title.localizedCaseInsensitiveContains(searchText) || note.body.localizedCaseInsensitiveContains(searchText)
            let mFolder = selectedFolder == nil || note.folder?.id == selectedFolder?.id
            let mFav = !showingFavoritesOnly || note.isFavorite
            return mSearch && mFolder && mFav
        }
    }
    private var pinned: [Note] { filteredNotes.filter(\.isPinned) }
    private var others: [Note] { filteredNotes.filter { !$0.isPinned } }

    var body: some View {
        NavigationStack {
            List {
                if filteredNotes.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Notes" : "No Results",
                        systemImage: searchText.isEmpty ? "doc.text" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Tap + to create your first note." : "Try a different search or filter.")
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    if !pinned.isEmpty {
                        Section { ForEach(pinned) { note in row(note) } } header: {
                            Label("Pinned", systemImage: "pin.fill").font(.caption.weight(.semibold))
                        }
                    }
                    Section {
                        ForEach(others) { note in row(note) }
                    } header: {
                        if !pinned.isEmpty { Text("Notes").font(.caption.weight(.semibold)) }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Notes")
            .searchable(text: $searchText, prompt: "Search notes")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button { selectedFolder = nil; showingFavoritesOnly = false } label: { Label("All Notes", systemImage: "tray.full") }
                        Button { showingFavoritesOnly.toggle(); if showingFavoritesOnly { selectedFolder = nil } } label: {
                            Label(showingFavoritesOnly ? "All Notes" : "Favorites", systemImage: "heart.fill")
                        }
                        if !folders.isEmpty {
                            Divider()
                            ForEach(folders) { f in
                                Button { selectedFolder = f; showingFavoritesOnly = false } label: { Label(f.name, systemImage: f.iconName) }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: selectedFolder?.iconName ?? (showingFavoritesOnly ? "heart.fill" : "line.3.horizontal.decrease.circle"))
                            Text(selectedFolder?.name ?? (showingFavoritesOnly ? "Favorites" : "Filter"))
                                .font(.subheadline.weight(.medium))
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showingNewNote = true } label: { Image(systemName: "plus") }
                }
            }
            .navigationDestination(for: Note.self) { note in NoteEditorView(note: note) }
            .sheet(isPresented: $showingNewNote) {
                NavigationStack { NoteEditorView(defaultFolder: selectedFolder) }
            }
            .animation(.default, value: filteredNotes)
        }
    }

    private func row(_ note: Note) -> some View {
        NavigationLink(value: note) { NoteRowView(note: note) }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) { withAnimation { modelContext.delete(note) } } label: { Label("Delete", systemImage: "trash") }
            }
            .swipeActions(edge: .leading) {
                Button { note.isPinned.toggle() } label: { Label(note.isPinned ? "Unpin" : "Pin", systemImage: "pin") }.tint(.orange)
                Button { note.isFavorite.toggle() } label: { Label("Favorite", systemImage: note.isFavorite ? "heart.slash" : "heart") }.tint(.pink)
            }
            .contextMenu {
                Button { note.isPinned.toggle() } label: { Label(note.isPinned ? "Unpin" : "Pin", systemImage: "pin") }
                Button { note.isFavorite.toggle() } label: { Label(note.isFavorite ? "Unfavorite" : "Favorite", systemImage: "heart") }
                Divider()
                Button(role: .destructive) { modelContext.delete(note) } label: { Label("Delete", systemImage: "trash") }
            }
    }
}
