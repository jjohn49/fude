import SwiftData
import Foundation

@Model
final class DailyLog {
    var id: UUID
    var date: Date                   // stored as start-of-day in local timezone

    @Relationship(deleteRule: .cascade)
    var entries: [FoodEntry]

    // Cached aggregate totals — call recalculateTotals() after any entry change
    var totalCalories: Double
    var totalProtein: Double
    var totalCarbohydrates: Double
    var totalFat: Double
    var totalFiber: Double

    // Water intake in millilitres (added in schema V2)
    var waterMl: Double

    var entryCount: Int { entries.count }

    func recalculateTotals() {
        totalCalories = entries.reduce(0) { $0 + $1.snapshotCalories }
        totalProtein = entries.reduce(0) { $0 + $1.snapshotProtein }
        totalCarbohydrates = entries.reduce(0) { $0 + $1.snapshotCarbohydrates }
        totalFat = entries.reduce(0) { $0 + $1.snapshotFat }
        totalFiber = 0
    }

    init(date: Date) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.entries = []
        self.totalCalories = 0
        self.totalProtein = 0
        self.totalCarbohydrates = 0
        self.totalFat = 0
        self.totalFiber = 0
        self.waterMl = 0
    }
}
