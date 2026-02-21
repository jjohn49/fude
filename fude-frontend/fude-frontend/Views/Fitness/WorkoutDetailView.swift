import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutSummary

    var body: some View {
        List {
            Section("Overview") {
                LabeledContent("Type", value: workout.workoutTypeName)
                LabeledContent("Date", value: workout.startDate.shortFormatted)
                LabeledContent("Duration", value: workout.durationFormatted)
                if let source = workout.sourceName {
                    LabeledContent("Source", value: source)
                }
            }

            Section("Calories") {
                if let active = workout.activeCaloriesBurned {
                    LabeledContent("Active", value: active.calorieString)
                }
                if let total = workout.totalCaloriesBurned {
                    LabeledContent("Total", value: total.calorieString)
                }
            }

            if workout.averageHeartRate != nil || workout.maxHeartRate != nil {
                Section("Heart Rate") {
                    if let avg = workout.averageHeartRate {
                        LabeledContent("Average", value: "\(avg.roundedCalories) bpm")
                    }
                    if let max = workout.maxHeartRate {
                        LabeledContent("Max", value: "\(max.roundedCalories) bpm")
                    }
                }
            }

            if let distance = workout.distanceMeters {
                Section("Distance") {
                    LabeledContent("Distance", value: String(format: "%.2f km", distance / 1000))
                }
            }

            if let steps = workout.stepCount {
                Section("Steps") {
                    LabeledContent("Steps", value: "\(steps)")
                }
            }
        }
        .navigationTitle(workout.workoutTypeName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
