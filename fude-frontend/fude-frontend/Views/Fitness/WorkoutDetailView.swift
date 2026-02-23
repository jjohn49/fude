import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutSummary

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SectionHeader(title: "Overview")
                VStack(spacing: 10) {
                    KeyValueRow(label: "Type", value: workout.workoutTypeName)
                    KeyValueRow(label: "Date", value: workout.startDate.shortFormatted)
                    KeyValueRow(label: "Duration", value: workout.durationFormatted, isMonospaced: true)
                    if let source = workout.sourceName {
                        KeyValueRow(label: "Source", value: source)
                    }
                }
                .padding(12)
                .background(Color.fudeSurface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 12)

                SectionHeader(title: "Calories")
                VStack(spacing: 10) {
                    if let active = workout.activeCaloriesBurned {
                        KeyValueRow(label: "Active", value: active.calorieString, isMonospaced: true)
                    }
                    if let total = workout.totalCaloriesBurned {
                        KeyValueRow(label: "Total", value: total.calorieString, isMonospaced: true)
                    }
                }
                .padding(12)
                .background(Color.fudeSurface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 12)

                if workout.averageHeartRate != nil || workout.maxHeartRate != nil {
                    SectionHeader(title: "Heart Rate")
                    VStack(spacing: 10) {
                        if let avg = workout.averageHeartRate {
                            KeyValueRow(label: "Average", value: "\(avg.roundedCalories) bpm", isMonospaced: true)
                        }
                        if let max = workout.maxHeartRate {
                            KeyValueRow(label: "Max", value: "\(max.roundedCalories) bpm", isMonospaced: true)
                        }
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)
                }

                if let distance = workout.distanceMeters {
                    SectionHeader(title: "Distance")
                    VStack(spacing: 10) {
                        KeyValueRow(label: "Distance", value: String(format: "%.2f km", distance / 1000), isMonospaced: true)
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)
                }

                if let steps = workout.stepCount {
                    SectionHeader(title: "Steps")
                    VStack(spacing: 10) {
                        KeyValueRow(label: "Steps", value: "\(steps)", isMonospaced: true)
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)
                }
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.fudeBackground)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TopBarTitle(text: workout.workoutTypeName)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
