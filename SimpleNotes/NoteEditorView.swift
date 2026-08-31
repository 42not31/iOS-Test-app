import SwiftUI
import SwiftData
import UIKit

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Folder.name) private var folders: [Folder]

    private var existingNote: Note?
    @State private var title: String
    @State private var noteBody: String
    @State private var isPinned: Bool
    @State private var isFavorite: Bool
    @State private var selectedColorHex: String
    @State private var selectedFolder: Folder?
    @State private var showingFolderPicker = false
    @State private var showingDeleteConfirm = false

    private let palette = ["", "00D2FF", "9D4EDD", "FF477E", "00F5D4", "FFB703", "3A86FF", "FF006E"]

    init(note: Note? = nil, defaultFolder: Folder? = nil) {
        self.existingNote = note
        _title = State(initialValue: note?.title ?? "")
        _noteBody = State(initialValue: note?.body ?? "")
        _isPinned = State(initialValue: note?.isPinned ?? false)
        _isFavorite = State(initialValue: note?.isFavorite ?? false)
        _selectedColorHex = State(initialValue: note?.colorHex ?? "")
        _selectedFolder = State(initialValue: note?.folder ?? defaultFolder)
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title, axis: .vertical)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                HStack {
                    Image(systemName: "folder").foregroundStyle(.secondary)
                    Picker("Folder", selection: $selectedFolder) {
                        Text("No Folder").tag(nil as Folder?)
                        ForEach(folders) { f in
                            Label(f.name, systemImage: f.iconName).tag(f as Folder?)
                        }
                    }
                    .labelsHidden()
                }
                HStack(spacing: 12) {
                    Toggle(isOn: $isPinned) { Label("Pinned", systemImage: "pin.fill") }
                    Divider()
                    Toggle(isOn: $isFavorite) { Label("Favorite", systemImage: "heart.fill") }
                }
                .tint(Color(hex: selectedColorHex.isEmpty ? "00D2FF" : selectedColorHex))
            }

            Section("Color") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(palette, id: \.self) { hex in
                            let sel = selectedColorHex == hex
                            Button {
                                withAnimation(.spring(response: 0.25)) { selectedColorHex = hex }
                            } label: {
                                ZStack {
                                    if hex.isEmpty {
                                        Circle().strokeBorder(.secondary, lineWidth: 1).frame(width: 30, height: 30)
                                        Image(systemName: "slash.circle").font(.caption2).foregroundStyle(.secondary)
                                    } else {
                                        Circle().fill(Color(hex: hex)).frame(width: 30, height: 30)
                                    }
                                    if sel { Circle().strokeBorder(.primary, lineWidth: 2).frame(width: 36, height: 36) }
                                }
                            }.buttonStyle(.plain)
                        }
                    }.padding(.vertical, 4)
                }.listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section("Body") {
                ZStack(alignment: .topLeading) {
                    if noteBody.isEmpty {
                        Text("Start writing...").foregroundStyle(.secondary).padding(.top, 8).padding(.leading, 4)
                    }
                    TextEditor(text: $noteBody).frame(minHeight: 280).scrollContentBackground(.hidden)
                }
            }

            Section {
                let wc = noteBody.split(whereSeparator: \.isWhitespace).count
                let cc = noteBody.count
                HStack {
                    Text("\(wc) words · \(cc) characters").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    if let n = existingNote { Text(n.updatedAt, style: .relative).font(.caption2).foregroundStyle(.secondary) }
                }
                .listRowBackground(Color.clear)
            }

            if existingNote != nil {
                Section {
                    Button(role: .destructive) { showingDeleteConfirm = true } label: {
                        HStack { Spacer(); Text("Delete Note"); Spacer() }
                    }
                }
            }
        }
        .navigationTitle(existingNote == nil ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save(); dismiss() }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && noteBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .bold()
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { hideKeyboard() }
            }
        }
        .alert("Delete Note?", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { if let n = existingNote { modelContext.delete(n) }; dismiss() }
        } message: { Text("This note will be permanently deleted.") }
    }

    private func save() {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = noteBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty || !b.isEmpty else { return }
        if let n = existingNote {
            n.title = title; n.body = noteBody; n.isPinned = isPinned; n.isFavorite = isFavorite; n.colorHex = selectedColorHex; n.folder = selectedFolder; n.updatedAt = .now
        } else {
            modelContext.insert(Note(title: title, body: noteBody, isPinned: isPinned, isFavorite: isFavorite, colorHex: selectedColorHex, folder: selectedFolder))
        }
    }
    private func hideKeyboard() { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
}
