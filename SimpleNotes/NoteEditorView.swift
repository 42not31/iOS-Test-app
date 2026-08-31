import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private var note: Note?
    @State private var title: String
    @State private var noteBody: String

    init(note: Note? = nil) {
        self.note = note
        _title = State(initialValue: note?.title ?? "")
        _noteBody = State(initialValue: note?.body ?? "")
    }

    var body: some View {
        Form {
            TextField("Title", text: $title, prompt: Text("Untitled"))
                .font(.headline)

            TextEditor(text: $noteBody)
                .frame(minHeight: 200)
                .overlay(alignment: .topLeading) {
                    if noteBody.isEmpty {
                        Text("Start writing...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                }
        }
        .navigationTitle(note == nil ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                    dismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty
                          && noteBody.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() {
        if let note {
            note.title = title
            note.body = noteBody
            note.updatedAt = .now
        } else {
            let note = Note(title: title, body: noteBody)
            modelContext.insert(note)
        }
    }
}
