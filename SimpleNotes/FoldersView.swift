import SwiftUI
import SwiftData

struct FoldersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]

    @State private var searchText = ""
    @State private var showingNewFolder = false
    @State private var folderToEdit: Folder?

    private var filtered: [Folder] {
        searchText.isEmpty ? folders : folders.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    private var unsortedCount: Int { allNotes.filter { $0.folder == nil }.count }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        FolderDetailView(folder: nil, title: "Unsorted", icon: "tray", colorHex: "8E8E93", notes: allNotes.filter { $0.folder == nil })
                    } label: {
                        Label {
                            HStack { Text("Unsorted"); Spacer(); Text("\(unsortedCount)").foregroundStyle(.secondary).monospacedDigit() }
                        } icon: { Image(systemName: "tray").foregroundStyle(.gray) }
                    }
                } header: { Text("System") }

                Section {
                    if filtered.isEmpty {
                        ContentUnavailableView(
                            searchText.isEmpty ? "No Folders" : "No Results",
                            systemImage: "folder",
                            description: Text(searchText.isEmpty ? "Create a folder to organize your notes." : "No folders match “\(searchText)”.")
                        ).listRowBackground(Color.clear).listRowSeparator(.hidden)
                    } else {
                        ForEach(filtered) { folder in
                            NavigationLink(value: folder) {
                                HStack(spacing: 12) {
                                    Image(systemName: folder.iconName)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .frame(width: 36, height: 36)
                                        .background { RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color(hex: folder.colorHex)) }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(folder.name).font(.body.weight(.medium))
                                        Text("\(folder.notes?.count ?? 0) notes").font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) { withAnimation { modelContext.delete(folder) } } label: { Label("Delete", systemImage: "trash") }
                            }
                            .swipeActions(edge: .leading) {
                                Button { folderToEdit = folder } label: { Label("Edit", systemImage: "pencil") }.tint(.blue)
                            }
                        }
                    }
                } header: { Text("My Folders") }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Folders")
            .searchable(text: $searchText, prompt: "Search folders")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingNewFolder = true } label: { Image(systemName: "folder.badge.plus") }
                }
            }
            .navigationDestination(for: Folder.self) { folder in
                FolderDetailView(folder: folder, title: folder.name, icon: folder.iconName, colorHex: folder.colorHex, notes: folder.notes ?? [])
            }
            .sheet(isPresented: $showingNewFolder) { FolderEditSheet() }
            .sheet(item: $folderToEdit) { f in FolderEditSheet(folder: f) }
        }
    }
}

struct FolderDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let folder: Folder?
    let title: String
    let icon: String
    let colorHex: String
    let notes: [Note]
    @State private var showingNewNote = false

    var body: some View {
        List {
            if notes.isEmpty {
                ContentUnavailableView("No Notes", systemImage: "doc.text", description: Text("Notes in this folder will appear here."))
                    .listRowBackground(Color.clear).listRowSeparator(.hidden)
            } else {
                ForEach(notes.sorted { $0.updatedAt > $1.updatedAt }) { note in
                    NavigationLink(value: note) { NoteRowView(note: note) }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingNewNote = true } label: { Image(systemName: "plus") }
            }
        }
        .navigationDestination(for: Note.self) { n in NoteEditorView(note: n) }
        .sheet(isPresented: $showingNewNote) {
            NavigationStack { NoteEditorView(defaultFolder: folder) }
        }
    }
}
