import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private var note: Note?
    @State private var title: String
    @State private var body: String

    init(note: Note? = nil) {
        self.note = note
        _title = State(initialValue: note?.title ?? "")
        _body = State(initialValue: note?.body ?? "")
    }

    var body: some View {
        Form {
            TextField("Title", text: $title, prompt: Text("Untitled"))
                .font(.headline)

            TextEditor(text: $body)
                .frame(minHeight: 200)
                .overlay(alignment: .topLeading) {
                    if body.isEmpty {
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
                          && body.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() {
        if let note {
            note.title = title
            note.body = body
            note.updatedAt = .now
        } else {
            let note = Note(title: title, body: body)
            modelContext.insert(note)
        }
    }
}
