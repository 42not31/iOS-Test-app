import SwiftUI
import UIKit

// Deprecated: custom floating glass tab bar was the "web app" look.
// Kept as stub for backward compat — ContentView now uses native TabView (iOS 18 Tab API)
// which on iOS 26 automatically renders as Liquid Glass. This file is no longer used.
enum AppTab: String, CaseIterable, Identifiable {
    case notes = "Notes", folders = "Folders", checklist = "Checklist", settings = "Settings"
    var id: String { rawValue }
}
struct GlassTabBar: View { @Binding var selectedTab: AppTab; var body: some View { EmptyView() } }
