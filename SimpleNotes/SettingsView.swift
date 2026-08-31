import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    @Query private var folders: [Folder]
    @Query private var checklistItems: [ChecklistItem]
    @AppStorage("accent_color_hex") private var accentHex = "00D2FF"
    @AppStorage("app_theme_mode") private var themeModeRaw = AppThemeMode.system.rawValue
    @State private var showingClearNotes = false
    @State private var showingClearAll = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles.rectangle.stack.fill").font(.largeTitle).foregroundStyle(Color(hex: accentHex))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SimpleNotes").font(.headline)
                            Text("Version 1.0 · Build 1").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    Text("Native iOS notes with folders & checklists. Built with SwiftUI + SwiftData. Liquid Glass renders automatically on iOS 26.")
                        .font(.caption).foregroundStyle(.secondary)
                    Link(destination: URL(string: "https://github.com/42not31/iOS-Test-app")!) {
                        Label("View on GitHub", systemImage: "link")
                    }
                } header: { Label("About", systemImage: "info.circle.fill") }

                Section {
                    Picker("Appearance", selection: $themeModeRaw) {
                        ForEach(AppThemeMode.allCases) { m in Text(m.rawValue).tag(m.rawValue) }
                    }.pickerStyle(.segmented)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accent Color").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            ForEach(AccentColorPreset.allCases) { p in
                                let sel = accentHex == p.rawValue
                                Button {
                                    withAnimation(.spring(response: 0.25)) { accentHex = p.rawValue }
                                } label: {
                                    HStack(spacing: 8) {
                                        Circle().fill(p.color).frame(width: 18, height: 18)
                                            .overlay { if sel { Circle().strokeBorder(.primary, lineWidth: 1.5).frame(width: 22, height: 22) } }
                                        Text(p.title).font(.caption2.weight(sel ? .bold : .medium)).lineLimit(1)
                                        Spacer()
                                        if sel { Image(systemName: "checkmark").font(.caption2.bold()) }
                                    }
                                    .padding(.horizontal, 10).padding(.vertical, 8)
                                    .background { RoundedRectangle(cornerRadius: 10, style: .continuous).fill(sel ? p.color.opacity(0.14) : Color(.secondarySystemBackground)) }
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                } header: { Label("Appearance", systemImage: "paintbrush.fill") }

                Section {
                    LabeledContent("Notes", value: "\(notes.count)")
                    LabeledContent("Folders", value: "\(folders.count)")
                    LabeledContent("Checklist Tasks", value: "\(checklistItems.count) (\(checklistItems.filter(\.isCompleted).count) done)")
                } header: { Label("Storage", systemImage: "internaldrive.fill") }

                Section {
                    Button(role: .destructive) { showingClearNotes = true } label: {
                        HStack { Spacer(); Label("Clear All Notes", systemImage: "trash"); Spacer() }
                    }.disabled(notes.isEmpty)
                    Button(role: .destructive) { showingClearAll = true } label: {
                        HStack { Spacer(); Label("Clear Everything", systemImage: "trash.fill"); Spacer() }
                    }.disabled(notes.isEmpty && folders.isEmpty && checklistItems.isEmpty)
                } header: { Label("Danger Zone", systemImage: "exclamationmark.triangle.fill") }
            }
            .navigationTitle("Settings")
            .alert("Clear All Notes?", isPresented: $showingClearNotes) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { for n in notes { modelContext.delete(n) } }
            } message: { Text("All notes will be permanently deleted.") }
            .alert("Clear Everything?", isPresented: $showingClearAll) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    for n in notes { modelContext.delete(n) }
                    for f in folders { modelContext.delete(f) }
                    for i in checklistItems { modelContext.delete(i) }
                }
            } message: { Text("All notes, folders and tasks will be deleted. This cannot be undone.") }
        }
    }
}
