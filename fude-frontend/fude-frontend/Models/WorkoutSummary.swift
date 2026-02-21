import SwiftData
import Foundation

@Model
final class WorkoutSummary {
    var id: UUID
    var healthKitUUID: String            // dedup key from HKWorkout.uuid
    var workoutTypeRawValue: Int         // HKWorkoutActivityType.rawValue
    var workoutTypeName: String
    var startDate: Date
    var endDate: Date
    var durationSeconds: Double
    var activeCaloriesBurned: Double?
    var totalCaloriesBurned: Double?
    var averageHeartRate: Double?
    var maxHeartRate: Double?
    var distanceMeters: Double?
    var stepCount: Int?
    var sourceName: String?
    var cachedAt: Date

    var durationFormatted: String {
        let mins = Int(durationSeconds) / 60
        let secs = Int(durationSeconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    init(
        healthKitUUID: String,
        workoutTypeRawValue: Int,
        workoutTypeName: String,
        startDate: Date,
        endDate: Date
    ) {
        self.id = UUID()
        self.healthKitUUID = healthKitUUID
        self.workoutTypeRawValue = workoutTypeRawValue
        self.workoutTypeName = workoutTypeName
        self.startDate = startDate
        self.endDate = endDate
        self.durationSeconds = endDate.timeIntervalSince(startDate)
        self.cachedAt = Date()
    }
}
