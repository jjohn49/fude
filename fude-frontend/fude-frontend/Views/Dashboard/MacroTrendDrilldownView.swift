import SwiftUI

/// Expanded dashboard panel for micronutrient details after ring->trend unravel.
struct MacroTrendDrilldownView: View {
    let dailyLogs: [DailyLog]

    @State private var showMicronutrients = true

    private var week: [DailyMicros] {
        let calendar = Calendar.current
        let today = Date().startOfDay

        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let log = dailyLogs.first(where: { $0.date == date })
            return DailyMicros(date: date, totals: micronutrients(from: log))
        }
    }

    private var todayTotals: MicronutrientTotals {
        week.last?.totals ?? .zero
    }

    private var weeklyAverage: MicronutrientTotals {
        guard !week.isEmpty else { return .zero }
        let total = week.reduce(.zero) { $0 + $1.totals }
        let divisor = Double(week.count)
        return .init(
            fiber: total.fiber / divisor,
            sugar: total.sugar / divisor,
            sodium: total.sodium / divisor
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.24)) {
                    showMicronutrients.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Micronutrients")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Spacer()
                    Image(systemName: showMicronutrients ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if showMicronutrients {
                VStack(spacing: 6) {
                    MicronutrientRow(
                        label: "Fiber",
                        todayValue: grams(todayTotals.fiber),
                        averageValue: grams(weeklyAverage.fiber),
                        color: .fudeFiber
                    )
                    MicronutrientRow(
                        label: "Sugar",
                        todayValue: grams(todayTotals.sugar),
                        averageValue: grams(weeklyAverage.sugar),
                        color: .fudeCarbs
                    )
                    MicronutrientRow(
                        label: "Sodium",
                        todayValue: mg(todayTotals.sodium),
                        averageValue: mg(weeklyAverage.sodium),
                        color: .gray
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.fudeSurface.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func micronutrients(from log: DailyLog?) -> MicronutrientTotals {
        guard let entries = log?.entries else { return .zero }

        return entries.reduce(into: .zero) { totals, entry in
            guard let food = entry.foodItem else { return }
            let multiplier = entry.quantityGrams / 100
            totals.fiber += (food.fiberPer100g ?? 0) * multiplier
            totals.sugar += (food.sugarPer100g ?? 0) * multiplier
            totals.sodium += (food.sodiumPer100mg ?? 0) * multiplier
        }
    }

    private func grams(_ value: Double) -> String {
        String(format: "%.1f g", value)
    }

    private func mg(_ value: Double) -> String {
        "\(Int(value.rounded())) mg"
    }
}

private struct DailyMicros {
    let date: Date
    let totals: MicronutrientTotals
}

private struct MicronutrientTotals {
    var fiber: Double
    var sugar: Double
    var sodium: Double

    static var zero: MicronutrientTotals {
        .init(fiber: 0, sugar: 0, sodium: 0)
    }

    static func + (lhs: MicronutrientTotals, rhs: MicronutrientTotals) -> MicronutrientTotals {
        .init(
            fiber: lhs.fiber + rhs.fiber,
            sugar: lhs.sugar + rhs.sugar,
            sodium: lhs.sodium + rhs.sodium
        )
    }
}

private struct MicronutrientRow: View {
    let label: String
    let todayValue: String
    let averageValue: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
            Text("Today \(todayValue)")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.white.opacity(0.88))
            Text("7d avg \(averageValue)")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    MacroTrendDrilldownView(dailyLogs: [])
        .padding()
        .background(Color.fudeBackground)
        .preferredColorScheme(.dark)
}
