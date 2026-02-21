import SwiftData
import Foundation

@Model
final class FoodItem {
    var id: UUID
    var externalID: String
    var source: String               // "openfoodfacts" | "usda"
    var name: String
    var brand: String?
    var servingSizeGrams: Double
    var servingSizeDescription: String
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbohydratesPer100g: Double
    var fatPer100g: Double
    var fiberPer100g: Double?
    var sugarPer100g: Double?
    var sodiumPer100mg: Double?
    var imageURL: String?
    var cachedAt: Date

    var caloriesForServing: Double {
        caloriesPer100g * servingSizeGrams / 100
    }

    init(externalID: String, source: String, name: String) {
        self.id = UUID()
        self.externalID = externalID
        self.source = source
        self.name = name
        self.servingSizeGrams = 100
        self.servingSizeDescription = "100g"
        self.caloriesPer100g = 0
        self.proteinPer100g = 0
        self.carbohydratesPer100g = 0
        self.fatPer100g = 0
        self.cachedAt = Date()
    }
}
