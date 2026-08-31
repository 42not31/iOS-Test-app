import SwiftUI
import SwiftData

struct FolderEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    private var existingFolder: Folder?
    @State private var folderName: String
    @State private var selectedIcon: String
    @State private var selectedColorHex: String

    private let icons = ["folder.fill","briefcase.fill","book.fill","sparkles","heart.fill","star.fill","lightbulb.fill","tray.fill","cart.fill","graduationcap.fill","music.note","gamecontroller.fill","airplane","hammer.fill","paintbrush.fill","checkmark.seal.fill"]
    private let colors = ["00D2FF","9D4EDD","FF477E","00F5D4","FFB703","3A86FF","FF5722","4CAF50"]

    init(folder: Folder? = nil) {
        self.existingFolder = folder
        _folderName = State(initialValue: folder?.name ?? "")
        _selectedIcon = State(initialValue: folder?.iconName ?? "folder.fill")
        _selectedColorHex = State(initialValue: folder?.colorHex ?? "00D2FF")
    }
    var selectedColor: Color { Color(hex: selectedColorHex) }

    var body: some View {
        NavigationStack {
            Form {
                Section("Preview") {
                    HStack(spacing: 12) {
                        Image(systemName: selectedIcon).font(.title2.weight(.semibold)).foregroundStyle(.white)
                            .frame(width: 44, height: 44).background { RoundedRectangle(cornerRadius: 10, style: .continuous).fill(selectedColor) }
                        Text(folderName.trimmingCharacters(in: .whitespaces).isEmpty ? "Folder Preview" : folderName).font(.headline)
                        Spacer()
                    }
                }
                Section("Name") {
                    TextField("Folder name", text: $folderName)
                }
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(colors, id: \.self) { hex in
                            let sel = selectedColorHex == hex
                            Button {
                                withAnimation(.spring(response: 0.25)) { selectedColorHex = hex }
                            } label: {
                                ZStack {
                                    Circle().fill(Color(hex: hex)).frame(width: 36, height: 36)
                                    if sel { Circle().strokeBorder(.primary, lineWidth: 2).frame(width: 42, height: 42) }
                                }
                            }.buttonStyle(.plain)
                        }
                    }.padding(.vertical, 4)
                }
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(icons, id: \.self) { ic in
                            let sel = selectedIcon == ic
                            Button {
                                withAnimation(.spring(response: 0.25)) { selectedIcon = ic }
                            } label: {
                                Image(systemName: ic).font(.title3)
                                    .frame(maxWidth: .infinity).frame(height: 44)
                                    .background { RoundedRectangle(cornerRadius: 10, style: .continuous).fill(sel ? selectedColor : Color(.secondarySystemBackground)) }
                                    .foregroundStyle(sel ? .white : .primary)
                                    .overlay { RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(sel ? Color.clear : Color.secondary.opacity(0.2), lineWidth: 1) }
                            }.buttonStyle(.plain)
                        }
                    }.padding(.vertical, 4)
                }
            }
            .navigationTitle(existingFolder == nil ? "New Folder" : "Edit Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }
                        .disabled(folderName.trimmingCharacters(in: .whitespaces).isEmpty).bold()
                }
            }
        }
    }
    private func save() {
        let t = folderName.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        if let f = existingFolder { f.name = t; f.iconName = selectedIcon; f.colorHex = selectedColorHex }
        else { modelContext.insert(Folder(name: t, iconName: selectedIcon, colorHex: selectedColorHex)) }
    }
}
