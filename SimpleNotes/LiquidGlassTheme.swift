import SwiftUI
import UIKit

// MARK: - Color Hex (kept for accent & folder tints)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 10, 132, 255)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
    func toHex() -> String {
        guard let c = UIColor(self).cgColor.components, c.count >= 3 else { return "0A84FF" }
        return String(format: "%02lX%02lX%02lX", lroundf(Float(c[0])*255), lroundf(Float(c[1])*255), lroundf(Float(c[2])*255))
    }
}

// MARK: - Accent Presets (used for tint + folder colors)
enum AccentColorPreset: String, CaseIterable, Identifiable {
    case electricCyan = "00D2FF", auroraViolet = "9D4EDD", neonCoral = "FF477E"
    case emeraldTeal = "00F5D4", sunsetGold = "FFB703", cosmicBlue = "3A86FF"
    var id: String { rawValue }
    var title: String {
        switch self {
        case .electricCyan: return "Liquid Cyan"; case .auroraViolet: return "Aurora Violet"
        case .neonCoral: return "Electric Coral"; case .emeraldTeal: return "Emerald Teal"
        case .sunsetGold: return "Sunset Gold"; case .cosmicBlue: return "Cosmic Blue"
        }
    }
    var color: Color { Color(hex: rawValue) }
}

// MARK: - Theme Mode
enum AppThemeMode: String, CaseIterable, Identifiable {
    case system = "System", light = "Light", dark = "Dark"
    var id: String { rawValue }
    var colorScheme: ColorScheme? {
        switch self { case .system: nil; case .light: .light; case .dark: .dark }
    }
}

// MARK: - Native Liquid Glass helpers
// On iOS 26 these map to the system .glassEffect — on iOS 18 they fall back to
// ultraThinMaterial so the app still builds with Xcode 16 while looking native.
// The "web-like" custom blobs / floating capsules are intentionally removed.

extension View {
    /// Subtle native glass for toolbars / FABs — on iOS 26 this would be .glassEffect.
    func nativeGlassCapsule(tint: Color? = nil) -> some View {
        self.background {
            Capsule().fill(.ultraThinMaterial)
                .overlay { if let t = tint { Capsule().fill(t.opacity(0.12)) } }
                .overlay { Capsule().strokeBorder(Color.white.opacity(0.22), lineWidth: 1) }
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
    }
    func nativeGlassRounded(_ radius: CGFloat = 16, tint: Color? = nil) -> some View {
        self.background {
            RoundedRectangle(cornerRadius: radius, style: .continuous).fill(.ultraThinMaterial)
                .overlay { if let t = tint { RoundedRectangle(cornerRadius: radius, style: .continuous).fill(t.opacity(0.10)) } }
                .overlay { RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(Color.white.opacity(0.18), lineWidth: 1) }
        }
    }
}
