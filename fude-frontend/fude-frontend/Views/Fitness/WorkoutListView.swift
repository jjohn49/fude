import SwiftUI
import SwiftData

struct WorkoutListView: View {
    // HealthKit integration is deferred until a paid Apple Developer account is available.
    // WorkoutSummary model and WorkoutDetailView are in place and ready —
    // re-enable by adding the HealthKit entitlement, capability, and HealthKitService (Phase 5).

    var body: some View {
        NavigationStack {
            EmptyStateView(
                systemImage: "figure.run.circle",
                title: "Fitness Tracking Coming Soon",
                message: "HealthKit integration requires an Apple Developer Program membership. Your workouts will appear here once the app is signed with a paid developer account."
            )
            .navigationTitle("Workouts")
        }
    }
}

private struct WorkoutRow: View {
    let workout: WorkoutSummary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.run")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(workout.workoutTypeName)
                    .font(.subheadline.bold())
                Text(workout.startDate.shortFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(workout.durationFormatted)
                    .font(.subheadline.monospacedDigit())
                if let cal = workout.activeCaloriesBurned {
                    Text("\(cal.roundedCalories) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
