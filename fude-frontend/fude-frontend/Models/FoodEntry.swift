import SwiftData
import Foundation

@Model
final class FoodEntry {
    var id: UUID
    var loggedAt: Date
    var mealName: String
    var quantityGrams: Double
    var notes: String?

    // Denormalised snapshot — accurate even if FoodItem cache changes later
    var snapshotCalories: Double
    var snapshotProtein: Double
    var snapshotCarbohydrates: Double
    var snapshotFat: Double

    @Relationship(deleteRule: .nullify)
    var foodItem: FoodItem?

    @Relationship(inverse: \DailyLog.entries)
    var dailyLog: DailyLog?

    init(foodItem: FoodItem, quantityGrams: Double, mealName: String) {
        self.id = UUID()
        self.loggedAt = Date()
        self.mealName = mealName
        self.quantityGrams = quantityGrams
        self.snapshotCalories = foodItem.caloriesPer100g * quantityGrams / 100
        self.snapshotProtein = foodItem.proteinPer100g * quantityGrams / 100
        self.snapshotCarbohydrates = foodItem.carbohydratesPer100g * quantityGrams / 100
        self.snapshotFat = foodItem.fatPer100g * quantityGrams / 100
        self.foodItem = foodItem
    }
}
