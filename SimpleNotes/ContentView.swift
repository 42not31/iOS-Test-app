import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("app_theme_mode") private var themeModeRaw = AppThemeMode.system.rawValue
    @State private var selectedTab: AppTab = .notes

    private var themeMode: AppThemeMode {
        AppThemeMode(rawValue: themeModeRaw) ?? .system
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .notes:
                    NotesListView()
                case .folders:
                    FoldersView()
                case .checklist:
                    ChecklistsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            GlassTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 8)
        }
        .preferredColorScheme(themeMode.colorScheme)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}
