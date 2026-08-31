import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    @Query private var folders: [Folder]
    @Query private var checklistItems: [ChecklistItem]

    @AppStorage("accent_color_hex") private var accentHex = "00D2FF"
    @AppStorage("app_theme_mode") private var themeModeRaw = AppThemeMode.system.rawValue

    @State private var showingClearNotesConfirm = false
    @State private var showingClearAllConfirm = false

    private var themeMode: AppThemeMode {
        AppThemeMode(rawValue: themeModeRaw) ?? .system
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidAmbientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Header
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Settings")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            Text("Personalize your liquid glass experience")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                        // Stats overview card
                        statsOverviewCard
                            .padding(.horizontal, 16)

                        // Appearance Section
                        settingsSection(title: "Appearance", icon: "paintbrush.fill", tint: Color(hex: "9D4EDD")) {
                            // Theme mode picker
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Theme")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                HStack(spacing: 8) {
                                    ForEach(AppThemeMode.allCases) { mode in
                                        let isSelected = (themeModeRaw == mode.rawValue)
                                        Button {
                                            themeModeRaw = mode.rawValue
                                        } label: {
                                            VStack(spacing: 6) {
                                                Image(systemName: mode == .system ? "circle.lefthalf.filled" : mode == .light ? "sun.max.fill" : "moon.fill")
                                                    .font(.system(size: 16))
                                                Text(mode.rawValue)
                                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(isSelected ? Color(hex: accentHex) : Color.clear)
                                                    .overlay { RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.2), lineWidth: 1) }
                                            }
                                            .foregroundStyle(isSelected ? .white : .primary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            Divider().opacity(0.3)

                            // Accent color picker
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Accent Color")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                                    ForEach(AccentColorPreset.allCases) { preset in
                                        let isSelected = (accentHex == preset.rawValue)
                                        Button {
                                            withAnimation(.spring(response: 0.3)) { accentHex = preset.rawValue }
                                        } label: {
                                            HStack(spacing: 8) {
                                                Circle().fill(preset.color).frame(width: 22, height: 22)
                                                    .overlay { if isSelected { Circle().strokeBorder(Color.white, lineWidth: 2).frame(width: 26, height: 26) } }
                                                Text(preset.title)
                                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(1)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 10).padding(.vertical, 10)
                                            .background {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(isSelected ? preset.color.opacity(0.18) : Color.white.opacity(0.08))
                                                    .strokeBorder(isSelected ? preset.color.opacity(0.5) : Color.white.opacity(0.15), lineWidth: 1)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        // Data & Storage Section
                        settingsSection(title: "Data & Storage", icon: "internaldrive.fill", tint: Color(hex: "00D2FF")) {
                            HStack {
                                Label("\(notes.count) Notes", systemImage: "note.text")
                                Spacer()
                                Text("\(notes.filter { $0.isPinned }.count) pinned").foregroundStyle(.secondary).font(.caption)
                            }
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            Divider().opacity(0.2)
                            HStack {
                                Label("\(folders.count) Folders", systemImage: "folder.fill")
                                Spacer()
                                Text("\(checklistItems.count) tasks").foregroundStyle(.secondary).font(.caption)
                            }
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            Divider().opacity(0.2)
                            Button(role: .destructive) { showingClearNotesConfirm = true } label: {
                                Label("Clear All Notes", systemImage: "trash")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .disabled(notes.isEmpty)
                            Button(role: .destructive) { showingClearAllConfirm = true } label: {
                                Label("Clear Everything", systemImage: "trash.fill")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .disabled(notes.isEmpty && folders.isEmpty && checklistItems.isEmpty)
                        }

                        // About Section
                        settingsSection(title: "About", icon: "info.circle.fill", tint: Color(hex: "FFB703")) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("SimpleNotes").font(.system(size: 15, weight: .bold, design: .rounded))
                                    Text("Version 1.0 · Build 1").font(.system(size: 12)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "sparkles")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color(hex: accentHex))
                            }
                            Text("A modern liquid glass note-taking experience built with SwiftUI & SwiftData. Organize thoughts into notes, folders, and checklists — all with a fluid, translucent design.")
                                .font(.system(size: 13)).foregroundStyle(.secondary).lineSpacing(2)
                            Divider().opacity(0.2)
                            Link(destination: URL(string: "https://github.com/42not31/iOS-Test-app")!) {
                                Label("View on GitHub", systemImage: "link")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 6)
                }
            }
            .alert("Clear All Notes?", isPresented: $showingClearNotesConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    for note in notes { modelContext.delete(note) }
                }
            } message: { Text("All notes will be permanently deleted. This cannot be undone.") }
            .alert("Clear Everything?", isPresented: $showingClearAllConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    for note in notes { modelContext.delete(note) }
                    for folder in folders { modelContext.delete(folder) }
                    for item in checklistItems { modelContext.delete(item) }
                }
            } message: { Text("All notes, folders, and checklist items will be permanently deleted.") }
        }
    }

    private var statsOverviewCard: some View {
        HStack(spacing: 12) {
            statMini(value: "\(notes.count)", label: "Notes", color: Color(hex: "00D2FF"))
            Divider().opacity(0.2)
            statMini(value: "\(folders.count)", label: "Folders", color: Color(hex: "9D4EDD"))
            Divider().opacity(0.2)
            statMini(value: "\(checklistItems.filter { $0.isCompleted }.count)/\(checklistItems.count)", label: "Tasks", color: Color(hex: "4CAF50"))
        }
        .padding(16)
        .liquidGlass(cornerRadius: 20, tint: Color(hex: accentHex), opacity: 0.7)
    }

    private func statMini(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(color)
            Text(label).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func settingsSection<Content: View>(title: String, icon: String, tint: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                    .padding(6).background { Circle().fill(tint) }
                Text(title).font(.system(size: 13, weight: .bold, design: .rounded)).foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 12) { content() }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 20)
        .padding(.horizontal, 16)
    }
}
