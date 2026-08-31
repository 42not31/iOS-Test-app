import SwiftUI

// MARK: - Kept minimal — native iOS components are preferred over custom glass.
// LiquidAmbientBackground (blobs) removed — it was the primary "web app" look.
// Use system grouped background + toolbar glass instead.

// MARK: - Native Badge (capsule with material, not heavy gradient)
struct GlassBadge: View {
    let title: String
    var icon: String? = nil
    var tint: Color? = nil
    var body: some View {
        HStack(spacing: 4) {
            if let icon { Image(systemName: icon).font(.caption2.weight(.semibold)) }
            Text(title).font(.caption2.weight(.semibold).monospacedDigit())
        }
        .padding(.horizontal, 7).padding(.vertical, 3)
        .background {
            Capsule().fill(.ultraThinMaterial)
                .overlay { if let t = tint { Capsule().fill(t.opacity(0.14)) } }
                .overlay { Capsule().strokeBorder(Color.white.opacity(0.22), lineWidth: 0.8) }
        }
        .foregroundStyle(tint ?? .secondary)
    }
}

// MARK: - Progress Ring (kept for checklists — native look)
struct ProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 5
    var size: CGFloat = 44
    var tint: Color = Color(hex: "00D2FF")
    var body: some View {
        ZStack {
            Circle().stroke(tint.opacity(0.15), lineWidth: lineWidth)
            Circle().trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
        }.frame(width: size, height: size)
    }
}
