import SwiftUI
import SwiftData

/// A 7-day workout tracker focused on calories burned and training consistency.
struct WeeklyInsightsView: View {
    let workouts: [WorkoutSummary]

    private var days: [DayWorkoutData] {
        let calendar = Calendar.current
        let today = Date().startOfDay

        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dayWorkouts = workouts.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
            let burned = dayWorkouts.reduce(0.0) { partial, workout in
                partial + (workout.activeCaloriesBurned ?? workout.totalCaloriesBurned ?? 0)
            }
            let durationMinutes = dayWorkouts.reduce(0.0) { $0 + $1.durationSeconds } / 60
            return DayWorkoutData(
                date: date,
                caloriesBurned: burned,
                workoutCount: dayWorkouts.count,
                durationMinutes: durationMinutes
            )
        }
    }

    private var activeDays: [DayWorkoutData] {
        days.filter { $0.workoutCount > 0 }
    }

    private var weeklyBurned: Double {
        days.reduce(0) { $0 + $1.caloriesBurned }
    }

    private var weeklySessions: Int {
        days.reduce(0) { $0 + $1.workoutCount }
    }

    private var weeklyMinutes: Double {
        days.reduce(0) { $0 + $1.durationMinutes }
    }

    private var averageBurnActiveDay: Double {
        guard !activeDays.isEmpty else { return 0 }
        return activeDays.reduce(0) { $0 + $1.caloriesBurned } / Double(activeDays.count)
    }

    private var maxBar: Double {
        max(250, days.map(\.caloriesBurned).max() ?? 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Training Week")
                    .font(.headline)
                Spacer()
                if weeklyBurned > 0 {
                    Text("\(Int(weeklyBurned)) kcal burned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { geo in
                let barWidth = (geo.size.width - CGFloat(days.count - 1) * 6) / CGFloat(days.count)

                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(days) { day in
                        VStack(spacing: 4) {
                            BarView(
                                caloriesBurned: day.caloriesBurned,
                                maxBar: maxBar,
                                isToday: day.date.isToday,
                                isActive: day.workoutCount > 0,
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
            .frame(height: 100)

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.fudeAccentPrimary)
                        .frame(width: 8, height: 8)
                    Text("\(weeklySessions) sessions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(activeDays.count)/7 active days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Avg \(Int(averageBurnActiveDay)) kcal/day")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if weeklySessions > 0 {
                Text("Volume \(Int(weeklyMinutes)) min")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Subviews

    private struct BarView: View {
        let caloriesBurned: Double
        let maxBar: Double
        let isToday: Bool
        let isActive: Bool
        let totalHeight: CGFloat

        private var fillFraction: CGFloat {
            guard maxBar > 0 else { return 0 }
            return CGFloat(min(caloriesBurned / maxBar, 1))
        }

        var body: some View {
            GeometryReader { geo in
                let barHeight = geo.size.height * fillFraction
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(height: max(barHeight, isActive ? 3 : 0))
                        .animation(.easeInOut(duration: 0.4), value: fillFraction)
                }
            }
            .frame(height: totalHeight)
        }

        private var barColor: Color {
            if isToday { return .fudeAccentPrimary }
            if isActive { return .fudeAccentPrimary.opacity(0.45) }
            return Color(.tertiarySystemFill)
        }
    }

    // MARK: - Data Model

    private struct DayWorkoutData: Identifiable {
        let id = UUID()
        let date: Date
        let caloriesBurned: Double
        let workoutCount: Int
        let durationMinutes: Double

        var dayLabel: String {
            if date.isToday { return "Today" }
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return String(formatter.string(from: date).prefix(1))
        }
    }
}

#Preview {
    WeeklyInsightsView(workouts: [])
        .padding()
}
