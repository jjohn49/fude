import SwiftUI

struct MacroBarView: View {
    let protein: Double
    let carbs: Double
    let fat: Double

    private var total: Double { protein + carbs + fat }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                HStack(spacing: 2) {
                    if total > 0 {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.fudeProtein)
                            .frame(width: geo.size.width * (protein / total))

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.fudeCarbs)
                            .frame(width: geo.size.width * (carbs / total))

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.fudeFat)
                            .frame(width: geo.size.width * (fat / total))
                    } else {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.3))
                    }
                }
                .frame(height: 8)
            }
            .frame(height: 8)

            HStack {
                MacroLabel(color: .fudeProtein, label: "Protein", value: protein)
                Spacer()
                MacroLabel(color: .fudeCarbs, label: "Carbs", value: carbs)
                Spacer()
                MacroLabel(color: .fudeFat, label: "Fat", value: fat)
            }
        }
    }
}

private struct MacroLabel: View {
    let color: Color
    let label: String
    let value: Double

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 0) {
                Text(value.gramString)
                    .font(.caption.bold())
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    MacroBarView(protein: 120, carbs: 180, fat: 55)
        .padding()
}
