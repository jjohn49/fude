import SwiftUI

struct FoodDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let foodItem: FoodItem
    var preselectedMeal: String? = nil
    var onLogged: (() -> Void)? = nil

    @State private var showAddEntry = false

    var body: some View {
        NavigationStack {
            List {
                // Header
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(foodItem.name)
                            .font(.title3.bold())
                        if let brand = foodItem.brand {
                            Text(brand)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text(foodItem.source == FoodSource.openFoodFacts ? "OpenFoodFacts" : "USDA")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(foodItem.source == FoodSource.openFoodFacts ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                                .foregroundStyle(foodItem.source == FoodSource.openFoodFacts ? Color.green : Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Nutrition facts per 100g
                Section("Nutrition per 100g") {
                    NutritionFactRow(label: "Calories", value: "\(foodItem.caloriesPer100g.roundedCalories) kcal", color: .fudeCalorieRing, isBold: true)
                    NutritionFactRow(label: "Protein", value: foodItem.proteinPer100g.gramString, color: .fudeProtein)
                    NutritionFactRow(label: "Carbohydrates", value: foodItem.carbohydratesPer100g.gramString, color: .fudeCarbs)
                    NutritionFactRow(label: "Fat", value: foodItem.fatPer100g.gramString, color: .fudeFat)
                    if let fiber = foodItem.fiberPer100g {
                        NutritionFactRow(label: "Fiber", value: fiber.gramString, color: .fudeFiber)
                    }
                    if let sugar = foodItem.sugarPer100g {
                        NutritionFactRow(label: "Sugar", value: sugar.gramString, color: .orange)
                    }
                    if let sodium = foodItem.sodiumPer100mg {
                        NutritionFactRow(label: "Sodium", value: "\(sodium.roundedCalories) mg", color: .gray)
                    }
                }

                // Serving info
                Section("Serving") {
                    LabeledContent("Serving size", value: foodItem.servingSizeDescription)
                }

                // Log button
                Section {
                    Button {
                        showAddEntry = true
                    } label: {
                        Label("Log this food", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.white)
                            .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.orange)
                }
            }
            .navigationTitle("Food Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showAddEntry) {
            AddFoodEntryView(
                foodItem: foodItem,
                preselectedMeal: preselectedMeal,
                onLogged: onLogged
            )
        }
    }
}

private struct NutritionFactRow: View {
    let label: String
    let value: String
    let color: Color
    var isBold: Bool = false

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(label).fontWeight(isBold ? .semibold : .regular)
            }
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .fontWeight(isBold ? .semibold : .regular)
                .monospacedDigit()
        }
    }
}
