import SwiftUI
import SwiftData

@main
struct SimpleNotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Note.self)
    }
}
