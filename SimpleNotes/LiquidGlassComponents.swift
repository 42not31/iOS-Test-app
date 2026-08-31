import SwiftUI

// MARK: - Liquid Ambient Glow Background
struct LiquidAmbientBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("accent_color_hex") private var accentHex: String = "00D2FF"

    var accentColor: Color {
        Color(hex: accentHex)
    }

    var body: some View {
        ZStack {
            // Base background
            if colorScheme == .dark {
                Color(red: 0.05, green: 0.06, blue: 0.10)
                    .ignoresSafeArea()
            } else {
                Color(red: 0.95, green: 0.96, blue: 0.98)
                    .ignoresSafeArea()
            }

            // Liquid Ambient Glowing Blobs
            GeometryReader { geometry in
                let size = geometry.size

                // Top Left Orb
                Circle()
                    .fill(accentColor.opacity(colorScheme == .dark ? 0.30 : 0.22))
                    .frame(width: size.width * 0.85, height: size.width * 0.85)
                    .blur(radius: 80)
                    .offset(x: -size.width * 0.25, y: -size.height * 0.15)

                // Top Right Purple Orb
                Circle()
                    .fill(Color(hex: "9D4EDD").opacity(colorScheme == .dark ? 0.25 : 0.18))
                    .frame(width: size.width * 0.75, height: size.width * 0.75)
                    .blur(radius: 75)
                    .offset(x: size.width * 0.45, y: size.height * 0.10)

                // Center-Bottom Coral Orb
                Circle()
                    .fill(Color(hex: "FF477E").opacity(colorScheme == .dark ? 0.20 : 0.15))
                    .frame(width: size.width * 0.70, height: size.width * 0.70)
                    .blur(radius: 85)
                    .offset(x: -size.width * 0.20, y: size.height * 0.55)

                // Bottom Right Indigo Orb
                Circle()
                    .fill(Color(hex: "3A86FF").opacity(colorScheme == .dark ? 0.28 : 0.18))
                    .frame(width: size.width * 0.80, height: size.width * 0.80)
                    .blur(radius: 80)
                    .offset(x: size.width * 0.35, y: size.height * 0.70)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Glass Badge
struct GlassBadge: View {
    let title: String
    var icon: String? = nil
    var tint: Color? = nil

    var body: some View {
        HStack(spacing: 5) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
            if let tint = tint {
                Capsule()
                    .fill(tint.opacity(0.15))
            }
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        }
        .foregroundStyle(tint ?? .primary)
    }
}

// MARK: - Glass Search Bar
struct GlassSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search notes, checklists..."
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .liquidGlass(cornerRadius: 16, opacity: 0.75)
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    var progress: Double // 0.0 to 1.0
    var lineWidth: CGFloat = 6
    var size: CGFloat = 40
    var tint: Color = Color(hex: "00D2FF")

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(tint.opacity(0.18), lineWidth: lineWidth)

            // Progress fill
            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0.0), 1.0)))
                .stroke(
                    LinearGradient(
                        colors: [tint, Color(hex: "9D4EDD")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Glass Segmented Control
struct GlassSegmentedControl<T: Hashable>: View {
    let items: [T]
    @Binding var selection: T
    let title: (T) -> String
    let icon: ((T) -> String)?

    init(
        items: [T],
        selection: Binding<T>,
        title: @escaping (T) -> String,
        icon: ((T) -> String)? = nil
    ) {
        self.items = items
        self._selection = selection
        self.title = title
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.self) { item in
                let isSelected = (selection == item)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selection = item
                    }
                } label: {
                    HStack(spacing: 5) {
                        if let icon = icon?(item) {
                            Image(systemName: icon)
                                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                        }
                        Text(title(item))
                            .font(.system(size: 13, weight: isSelected ? .semibold : .medium, design: .rounded))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                }
                                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                        }
                    }
                    .foregroundStyle(isSelected ? .primary : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.8)
        }
    }
}
