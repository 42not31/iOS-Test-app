import SwiftUI
import SwiftData

struct FoldersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]

    @State private var showingNewFolder = false
    @State private var folderToEdit: Folder?
    @State private var searchText = ""

    private var filteredFolders: [Folder] {
        if searchText.isEmpty { return folders }
        return folders.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var notesWithoutFolderCount: Int {
        allNotes.filter { $0.folder == nil }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidAmbientBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Folders")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                Text("\(folders.count) folders · \(allNotes.count) notes")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                showingNewFolder = true
                            } label: {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background {
                                        Circle()
                                            .fill(LinearGradient(colors: [Color(hex: "00D2FF"), Color(hex: "3A86FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .shadow(color: Color(hex: "00D2FF").opacity(0.4), radius: 8, x: 0, y: 3)
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                        GlassSearchBar(text: $searchText, placeholder: "Search folders...")
                            .padding(.horizontal, 16)

                        // Stats strip
                        HStack(spacing: 12) {
                            statCard(title: "Total", value: "\(folders.count)", icon: "folder.fill", tint: Color(hex: "00D2FF"))
                            statCard(title: "Notes", value: "\(allNotes.count)", icon: "note.text", tint: Color(hex: "9D4EDD"))
                            statCard(title: "Unsorted", value: "\(notesWithoutFolderCount)", icon: "tray", tint: Color(hex: "FFB703"))
                        }
                        .padding(.horizontal, 16)

                        if filteredFolders.isEmpty && searchText.isEmpty {
                            emptyFoldersView
                                .padding(.horizontal, 16)
                                .padding(.top, 20)
                        } else if filteredFolders.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.secondary)
                                Text("No folders match \"\(searchText)\"")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                ForEach(filteredFolders) { folder in
                                    NavigationLink(value: folder) {
                                        folderCard(folder: folder)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button { folderToEdit = folder } label: { Label("Edit Folder", systemImage: "pencil") }
                                        Button(role: .destructive) {
                                            withAnimation { modelContext.delete(folder) }
                                        } label: { Label("Delete Folder", systemImage: "trash") }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 6)
                }
            }
            .navigationDestination(for: Folder.self) { folder in
                FolderDetailView(folder: folder)
            }
            .sheet(isPresented: $showingNewFolder) {
                FolderEditSheet()
            }
            .sheet(item: $folderToEdit) { folder in
                FolderEditSheet(folder: folder)
            }
        }
    }

    private func statCard(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .liquidGlass(cornerRadius: 16, tint: tint, opacity: 0.6)
    }

    private func folderCard(folder: Folder) -> some View {
        let count = folder.notes?.count ?? 0
        let color = Color(hex: folder.colorHex)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle().fill(color.opacity(0.2)).frame(width: 44, height: 44)
                    Circle().fill(color).frame(width: 38, height: 38)
                    Image(systemName: folder.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Spacer()
                GlassBadge(title: "\(count)", icon: "doc.text", tint: color)
            }
            Text(folder.name)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .lineLimit(1)
            Text(count == 1 ? "1 note" : "\(count) notes")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .liquidGlass(cornerRadius: 18, tint: color, opacity: 0.7)
    }

    private var emptyFoldersView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "00D2FF").opacity(0.25), Color(hex: "9D4EDD").opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90).blur(radius: 8)
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(Color(hex: "00D2FF"))
            }
            Text("No Folders Yet")
                .font(.system(size: 19, weight: .bold, design: .rounded))
            Text("Group your notes into folders to stay organized.")
                .font(.system(size: 14)).foregroundStyle(.secondary)
                .multilineTextAlignment(.center).padding(.horizontal, 24)
            Button { showingNewFolder = true } label: {
                HStack(spacing: 8) { Image(systemName: "plus.circle.fill"); Text("Create Folder").fontWeight(.semibold) }
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background { Capsule().fill(LinearGradient(colors: [Color(hex: "00D2FF"), Color(hex: "3A86FF")], startPoint: .topLeading, endPoint: .bottomTrailing)).shadow(color: Color(hex: "00D2FF").opacity(0.4), radius: 10, x: 0, y: 4) }
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .liquidGlass(cornerRadius: 24, opacity: 0.5)
    }
}

struct FolderDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let folder: Folder
    @State private var showingNewNote = false

    private var sortedNotes: [Note] {
        (folder.notes ?? []).sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        ZStack {
            LiquidAmbientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Folder header card
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Color(hex: folder.colorHex).opacity(0.2)).frame(width: 56, height: 56)
                            Circle().fill(Color(hex: folder.colorHex)).frame(width: 48, height: 48)
                            Image(systemName: folder.iconName).font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(folder.name).font(.system(size: 20, weight: .bold, design: .rounded))
                            Text("\(sortedNotes.count) notes").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button { showingNewNote = true } label: {
                            Image(systemName: "plus").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                                .padding(10)
                                .background { Circle().fill(Color(hex: folder.colorHex)).shadow(color: Color(hex: folder.colorHex).opacity(0.4), radius: 6) }
                        }
                    }
                    .padding(16)
                    .liquidGlass(cornerRadius: 20, tint: Color(hex: folder.colorHex), opacity: 0.7)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    if sortedNotes.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "note.text").font(.system(size: 32)).foregroundStyle(.secondary)
                            Text("No notes in this folder").foregroundStyle(.secondary)
                            Button("Add a Note") { showingNewNote = true }
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 40)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(sortedNotes) { note in
                                NavigationLink(value: note) {
                                    NoteRowView(note: note)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Note.self) { note in NoteEditorView(note: note) }
        .sheet(isPresented: $showingNewNote) { NoteEditorView(defaultFolder: folder) }
    }
}
