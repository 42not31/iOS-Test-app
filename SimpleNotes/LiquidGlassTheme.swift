import SwiftUI
import UIKit

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 10, 132, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "0A84FF"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

// MARK: - Accent Color Presets
enum AccentColorPreset: String, CaseIterable, Identifiable {
    case electricCyan = "00D2FF"
    case auroraViolet = "9D4EDD"
    case neonCoral    = "FF477E"
    case emeraldTeal  = "00F5D4"
    case sunsetGold   = "FFB703"
    case cosmicBlue   = "3A86FF"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .electricCyan: return "Liquid Cyan"
        case .auroraViolet: return "Aurora Violet"
        case .neonCoral:    return "Electric Coral"
        case .emeraldTeal:  return "Emerald Teal"
        case .sunsetGold:   return "Sunset Gold"
        case .cosmicBlue:   return "Cosmic Blue"
        }
    }

    var color: Color {
        Color(hex: rawValue)
    }
}

// MARK: - Theme Mode
enum AppThemeMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Liquid Glass Modifiers & Styles
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var tint: Color? = nil
    var opacity: Double = 0.65
    var glowRadius: CGFloat = 0

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(opacity)

                    if let tint = tint {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tint.opacity(colorScheme == .dark ? 0.12 : 0.08))
                    }

                    // Specular glass highlight on border
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: colorScheme == .dark ? [
                                    .white.opacity(0.35),
                                    .white.opacity(0.08),
                                    .clear,
                                    .white.opacity(0.15)
                                ] : [
                                    .white.opacity(0.8),
                                    .white.opacity(0.2),
                                    .white.opacity(0.05),
                                    .white.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: tint?.opacity(glowRadius > 0 ? 0.3 : 0) ?? Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06),
                    radius: glowRadius > 0 ? glowRadius : 12,
                    x: 0,
                    y: 6
                )
            }
    }
}

struct LiquidGlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 22
    var tint: Color? = nil
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(16)
            .modifier(LiquidGlassModifier(cornerRadius: cornerRadius, tint: tint, opacity: 0.8))
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 20, tint: Color? = nil, opacity: Double = 0.7, glowRadius: CGFloat = 0) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, tint: tint, opacity: opacity, glowRadius: glowRadius))
    }

    func liquidGlassCard(cornerRadius: CGFloat = 22, tint: Color? = nil) -> some View {
        self.modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius, tint: tint))
    }
}
