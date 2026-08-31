import SwiftUI
import UIKit

enum AppTab: String, CaseIterable, Identifiable {
    case notes = "Notes"
    case folders = "Folders"
    case checklist = "Checklist"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .notes: return "doc.text"
        case .folders: return "folder"
        case .checklist: return "checklist"
        case .settings: return "gearshape"
        }
    }

    var filledIcon: String {
        switch self {
        case .notes: return "doc.text.fill"
        case .folders: return "folder.fill"
        case .checklist: return "checklist"
        case .settings: return "gearshape.fill"
        }
    }
}

struct GlassTabBar: View {
    @Binding var selectedTab: AppTab
    @AppStorage("accent_color_hex") private var accentHex = "00D2FF"

    var accentColor: Color { Color(hex: accentHex) }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = (selectedTab == tab)
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: isSelected ? tab.filledIcon : tab.icon)
                            .font(.system(size: isSelected ? 20 : 18, weight: isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? accentColor : .secondary)
                            .frame(height: 22)
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: isSelected ? .bold : .medium, design: .rounded))
                            .foregroundStyle(isSelected ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(accentColor.opacity(0.14))
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                }
                                .shadow(color: accentColor.opacity(0.25), radius: 6, x: 0, y: 3)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.5), Color.white.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
                .shadow(color: accentColor.opacity(0.12), radius: 12, x: 0, y: 4)
        }
        .padding(.horizontal, 16)
    }
}
