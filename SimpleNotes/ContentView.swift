import SwiftUI

struct ContentView: View {
    @AppStorage("app_theme_mode") private var themeModeRaw = AppThemeMode.system.rawValue
    @AppStorage("accent_color_hex") private var accentHex = "00D2FF"

    private var themeMode: AppThemeMode {
        AppThemeMode(rawValue: themeModeRaw) ?? .system
    }

    var body: some View {
        TabView {
            Tab("Notes", systemImage: "doc.text") {
                NotesListView()
            }
            Tab("Folders", systemImage: "folder") {
                FoldersView()
            }
            Tab("Checklist", systemImage: "checklist") {
                ChecklistsView()
            }
            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .preferredColorScheme(themeMode.colorScheme)
        .tint(Color(hex: accentHex))
    }
}
