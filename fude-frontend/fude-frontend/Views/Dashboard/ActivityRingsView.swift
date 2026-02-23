import SwiftUI

/// Apple Watch-style concentric progress rings.
/// Pass rings outermost-first; each successive ring is drawn smaller.
struct ActivityRingsView: View {

    struct Ring: Identifiable {
        let id = UUID()
        /// Clamped progress value 0.0–1.0 (visual) — allow up to 1.05 for a tiny overshoot glow
        let progress: Double
        let color: Color
        var lineWidth: CGFloat = 16
    }

    let rings: [Ring]

    /// Gap between adjacent ring tracks in points
    private let ringGap: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                ForEach(Array(rings.enumerated()), id: \.offset) { index, ring in
                    let radius = (size / 2) - CGFloat(index) * (ring.lineWidth + ringGap) - ring.lineWidth / 2
                    let diameter = radius * 2

                    // Dim background track
                    Circle()
                        .stroke(ring.color.opacity(0.18), lineWidth: ring.lineWidth)
                        .frame(width: diameter, height: diameter)

                    // Coloured progress arc
                    Circle()
                        .trim(from: 0, to: min(ring.progress, 1.0))
                        .stroke(
                            ring.color,
                            style: StrokeStyle(lineWidth: ring.lineWidth, lineCap: .round)
                        )
                        .frame(width: diameter, height: diameter)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: ring.color.opacity(0.6), radius: 6, x: 0, y: 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.75).delay(Double(index) * 0.08),
                            value: ring.progress
                        )
                }
            }
            .frame(width: size, height: size)
            // Centre the ZStack within the GeometryReader
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ActivityRingsView(rings: [
        .init(progress: 0.62, color: .fudeCalorieRing),
        .init(progress: 0.84, color: Color(red: 0.29, green: 0.56, blue: 0.89)),
        .init(progress: 0.45, color: Color(red: 0.95, green: 0.77, blue: 0.06)),
        .init(progress: 0.71, color: Color(red: 0.93, green: 0.44, blue: 0.32)),
    ])
    .frame(width: 200, height: 200)
    .padding(32)
    .background(Color(red: 0.08, green: 0.08, blue: 0.13))
    .clipShape(RoundedRectangle(cornerRadius: 24))
}
