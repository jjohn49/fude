import SwiftUI
import SwiftData

/// A 7-day calorie bar chart for the current week, with a goal line.
struct WeeklyInsightsView: View {
    let dailyLogs: [DailyLog]
    let calorieTarget: Double

    private var days: [DayData] {
        let calendar = Calendar.current
        let today = Date().startOfDay
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let log = dailyLogs.first(where: { $0.date == date })
            return DayData(date: date, calories: log?.totalCalories ?? 0, isLogged: log != nil && (log?.totalCalories ?? 0) > 0)
        }
    }

    private var loggedDays: [DayData] { days.filter { $0.isLogged } }
    private var averageCalories: Double {
        guard !loggedDays.isEmpty else { return 0 }
        return loggedDays.reduce(0) { $0 + $1.calories } / Double(loggedDays.count)
    }

    private var maxBar: Double {
        max(calorieTarget * 1.3, days.map(\.calories).max() ?? calorieTarget)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.headline)
                Spacer()
                if !loggedDays.isEmpty {
                    Text("Avg \(Int(averageCalories)) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { geo in
                let barWidth = (geo.size.width - CGFloat(days.count - 1) * 6) / CGFloat(days.count)
                let goalY = geo.size.height * (1 - min(calorieTarget / maxBar, 1))

                ZStack(alignment: .topLeading) {
                    // Goal line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: goalY))
                        path.addLine(to: CGPoint(x: geo.size.width, y: goalY))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.secondary.opacity(0.4))

                    // Bars
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(days) { day in
                            VStack(spacing: 4) {
                                BarView(
                                    calories: day.calories,
                                    maxBar: maxBar,
                                    isToday: day.date.isToday,
                                    isLogged: day.isLogged,
                                    totalHeight: geo.size.height - 20
                                )
                                .frame(width: barWidth)

                                Text(day.dayLabel)
                                    .font(.caption2)
                                    .foregroundStyle(day.date.isToday ? Color.primary : Color.secondary)
                                    .frame(width: barWidth)
                            }
                        }
                    }
                }
            }
            .frame(height: 100)

            // Summary row
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.fudeCalorieRing)
                        .frame(width: 8, height: 8)
                    Text("\(loggedDays.count)/7 days logged")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Path { path in
                        path.move(to: .zero)
                        path.addLine(to: CGPoint(x: 16, y: 0))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    .foregroundStyle(Color.secondary.opacity(0.6))
                    .frame(width: 16, height: 1)

                    Text("Goal \(Int(calorieTarget)) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Subviews

    private struct BarView: View {
        let calories: Double
        let maxBar: Double
        let isToday: Bool
        let isLogged: Bool
        let totalHeight: CGFloat

        private var fillFraction: CGFloat {
            guard maxBar > 0 else { return 0 }
            return CGFloat(min(calories / maxBar, 1))
        }

        var body: some View {
            GeometryReader { geo in
                let barHeight = geo.size.height * fillFraction
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(height: max(barHeight, isLogged ? 3 : 0))
                        .animation(.easeInOut(duration: 0.4), value: fillFraction)
                }
            }
            .frame(height: totalHeight)
        }

        private var barColor: Color {
            if isToday { return .fudeCalorieRing }
            if isLogged { return .fudeCalorieRing.opacity(0.45) }
            return Color(.tertiarySystemFill)
        }
    }

    // MARK: - Data Model

    private struct DayData: Identifiable {
        let id = UUID()
        let date: Date
        let calories: Double
        let isLogged: Bool

        var dayLabel: String {
            if date.isToday { return "Today" }
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return String(formatter.string(from: date).prefix(1))
        }
    }
}

#Preview {
    WeeklyInsightsView(dailyLogs: [], calorieTarget: 2000)
        .padding()
}
