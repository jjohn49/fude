import SwiftUI

struct FoodDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let foodItem: FoodItem
    var preselectedMeal: String? = nil
    var onLogged: (() -> Void)? = nil

    @State private var showAddEntry = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
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
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(foodItem.source == FoodSource.openFoodFacts ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                                .foregroundStyle(foodItem.source == FoodSource.openFoodFacts ? Color.green : Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)

                    SectionHeader(title: "Nutrition per 100g")
                    VStack(spacing: 10) {
                        NutritionFactRow(label: "Calories", value: "\(foodItem.caloriesPer100g.roundedCalories) kcal", color: .fudeCalorieRing, isBold: true)
                        NutritionFactRow(label: "Protein", value: foodItem.proteinPer100g.gramString, color: .fudeProtein)
                        NutritionFactRow(label: "Carbohydrates", value: foodItem.carbohydratesPer100g.gramString, color: .fudeCarbs)
                        NutritionFactRow(label: "Fat", value: foodItem.fatPer100g.gramString, color: .fudeFat)
                        if let fiber = foodItem.fiberPer100g {
                            NutritionFactRow(label: "Fiber", value: fiber.gramString, color: .fudeFiber)
                        }
                        if let sugar = foodItem.sugarPer100g {
                            NutritionFactRow(label: "Sugar", value: sugar.gramString, color: .fudeCarbs)
                        }
                        if let sodium = foodItem.sodiumPer100mg {
                            NutritionFactRow(label: "Sodium", value: "\(sodium.roundedCalories) mg", color: .gray)
                        }
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)

                    SectionHeader(title: "Serving")
                    VStack(spacing: 10) {
                        KeyValueRow(label: "Serving size", value: foodItem.servingSizeDescription)
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)

                    Button {
                        showAddEntry = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("Log this food")
                        }
                    }
                    .buttonStyle(FudePrimaryButtonStyle())
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.fudeBackground)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TopBarTitle(text: "Food Details")
                }
                ToolbarItem(placement: .cancellationAction) {
                    TopBarTextButton(title: "Back", systemImage: "chevron.left") { dismiss() }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .sheet(isPresented: $showAddEntry) {
            AddFoodEntryView(
                foodItem: foodItem,
                targetDate: Date(),
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
