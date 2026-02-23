//
//  PreviewContainer+Fude.swift
//  fude-frontend
//
//  Created by John Johnston on 2/21/26.
//

import SwiftUI
import SwiftData

/// Helper to create an in-memory SwiftData container for Canvas previews.
/// This ensures previews have access to the full data model without persisting changes.
@MainActor
func previewContainer() -> ModelContainer {
    let schema = Schema(versionedSchema: FudeSchemaV2.self)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    guard let container = try? ModelContainer(
        for: schema,
        migrationPlan: FudeMigrationPlan.self,
        configurations: [config]
    ) else {
        fatalError("Failed to create preview container")
    }

    return container
}

/// Helper to create a preview container with sample data pre-populated.
@MainActor
func previewContainerWithSampleData() -> ModelContainer {
    let container = previewContainer()
    let context = container.mainContext

    // Create sample user profile
    let profile = UserProfile(
        appleUserIdentifier: "preview.user.123",
        displayName: "Preview User",
        email: "preview@example.com"
    )
    profile.dailyCalorieTarget = 2000
    profile.dailyProteinTarget = 150
    profile.dailyCarbohydrateTarget = 200
    profile.dailyFatTarget = 65
    context.insert(profile)

    // Create sample food items
    let apple = FoodItem(externalID: "preview-apple", source: "openfoodfacts", name: "Apple")
    apple.caloriesPer100g = 52
    apple.proteinPer100g = 0.3
    apple.carbohydratesPer100g = 14
    apple.fatPer100g = 0.2
    context.insert(apple)

    let chicken = FoodItem(externalID: "preview-chicken", source: "usda", name: "Grilled Chicken Breast")
    chicken.brand = "Generic"
    chicken.caloriesPer100g = 165
    chicken.proteinPer100g = 31
    chicken.carbohydratesPer100g = 0
    chicken.fatPer100g = 3.6
    context.insert(chicken)

    let rice = FoodItem(externalID: "preview-rice", source: "usda", name: "Brown Rice (Cooked)")
    rice.caloriesPer100g = 111
    rice.proteinPer100g = 2.6
    rice.carbohydratesPer100g = 23
    rice.fatPer100g = 0.9
    context.insert(rice)

    // Create today's log with sample entries and water intake
    let todayLog = DailyLog(date: Date())
    todayLog.waterMl = 750
    context.insert(todayLog)

    let breakfastEntry = FoodEntry(foodItem: apple, quantityGrams: 150, mealName: "Breakfast")
    context.insert(breakfastEntry)
    breakfastEntry.dailyLog = todayLog
    todayLog.entries.append(breakfastEntry)

    let lunchEntry1 = FoodEntry(foodItem: chicken, quantityGrams: 200, mealName: "Lunch")
    context.insert(lunchEntry1)
    lunchEntry1.dailyLog = todayLog
    todayLog.entries.append(lunchEntry1)

    let lunchEntry2 = FoodEntry(foodItem: rice, quantityGrams: 150, mealName: "Lunch")
    context.insert(lunchEntry2)
    lunchEntry2.dailyLog = todayLog
    todayLog.entries.append(lunchEntry2)

    todayLog.recalculateTotals()

    // Sample body weight entries
    let cal = Calendar.current
    let bw1 = BodyWeightEntry(
        date: cal.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
        weightKg: 82.5
    )
    let bw2 = BodyWeightEntry(
        date: cal.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
        weightKg: 82.1,
        note: "morning"
    )
    let bw3 = BodyWeightEntry(weightKg: 81.8, note: "post-workout")
    context.insert(bw1)
    context.insert(bw2)
    context.insert(bw3)

    try? context.save()

    return container
}
