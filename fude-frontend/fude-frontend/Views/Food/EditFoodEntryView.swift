import SwiftUI
import SwiftData

struct EditFoodEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let entry: FoodEntry

    @State private var selectedUnit: QuantityUnit = .servings
    @State private var quantityText: String = ""
    @State private var selectedMeal: String = "Breakfast"
    @State private var notes: String = ""

    private let meals = ["Breakfast", "Lunch", "Dinner", "Snack"]

    // MARK: Quantity helpers

    private var servingSizeGrams: Double { entry.foodItem?.servingSizeGrams ?? 100 }

    private var quantityInGrams: Double {
        let raw = Double(quantityText) ?? 0
        switch selectedUnit {
        case .servings: return raw * max(servingSizeGrams, 1)
        case .grams:    return raw
        case .lbs:      return raw * 453.592
        }
    }

    private var unitLabel: String {
        switch selectedUnit {
        case .servings: return "servings"
        case .grams:    return "g"
        case .lbs:      return "lbs"
        }
    }

    private var quickValues: [Double] {
        switch selectedUnit {
        case .servings: return [0.5, 1.0, 1.5, 2.0]
        case .grams:    return [50, 100, 150, 200]
        case .lbs:      return [0.25, 0.5, 1.0, 2.0]
        }
    }

    private func quickLabel(_ val: Double) -> String {
        switch selectedUnit {
        case .servings:
            if val == 0.5 { return "½" }
            if val == 1.5 { return "1½" }
            return "\(Int(val))"
        case .grams:
            return "\(Int(val))g"
        case .lbs:
            if val == 0.25 { return "¼ lb" }
            if val == 0.5  { return "½ lb" }
            return "\(Int(val)) lb"
        }
    }

    private func isQuickSelected(_ val: Double) -> Bool {
        abs((Double(quantityText) ?? -1) - val) < 0.001
    }

    private func resetQuantityForUnit() {
        switch selectedUnit {
        case .servings: quantityText = "1"
        case .grams:    quantityText = "100"
        case .lbs:      quantityText = "0.5"
        }
    }

    // Live-preview macros based on current quantity input
    private var scaledCalories: Double { (entry.foodItem?.caloriesPer100g ?? 0).scaled(by: quantityInGrams) }
    private var scaledProtein: Double  { (entry.foodItem?.proteinPer100g ?? 0).scaled(by: quantityInGrams) }
    private var scaledCarbs: Double    { (entry.foodItem?.carbohydratesPer100g ?? 0).scaled(by: quantityInGrams) }
    private var scaledFat: Double      { (entry.foodItem?.fatPer100g ?? 0).scaled(by: quantityInGrams) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.foodItem?.name ?? "Unknown food")
                            .font(.headline)
                        if let brand = entry.foodItem?.brand {
                            Text(brand)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)

                    SectionHeader(title: "Quantity")
                    VStack(spacing: 12) {
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(QuantityUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(.fudeAccentPrimary)
                        .onChange(of: selectedUnit) { _, _ in resetQuantityForUnit() }

                        HStack {
                            TextField(text: $quantityText, prompt: Text("Amount").foregroundStyle(.secondary)) {
                                Text("Amount")
                            }
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.primary)
                            .foregroundColor(.white)
                            Text(unitLabel)
                                .foregroundStyle(.secondary)
                        }

                        HStack(spacing: 8) {
                            ForEach(quickValues, id: \.self) { val in
                                Button(quickLabel(val)) {
                                    quantityText = val == Double(Int(val)) ? "\(Int(val))" : "\(val)"
                                }
                                .buttonStyle(FudeGhostButtonStyle(tint: isQuickSelected(val) ? .fudeAccentPrimary : .secondary))
                            }
                        }

                        if selectedUnit == .servings {
                            HStack(spacing: 4) {
                                Image(systemName: "info.circle")
                                    .font(.caption2)
                                Text("1 serving = \(Int(servingSizeGrams))g")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)

                    SectionHeader(title: "Meal")
                    VStack(spacing: 10) {
                        Menu {
                            ForEach(meals, id: \.self) { meal in
                                Button(meal) { selectedMeal = meal }
                            }
                        } label: {
                            HStack {
                                Text(selectedMeal)
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .foregroundStyle(.primary)
                            .padding(.vertical, 6)
                        }
                        .tint(.fudeAccentPrimary)
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)

                    SectionHeader(title: "Nutrition (Estimated)")
                    VStack(spacing: 10) {
                        NutritionEditRow(label: "Calories", value: scaledCalories.calorieString, color: .fudeCalorieRing)
                        NutritionEditRow(label: "Protein", value: scaledProtein.gramString, color: .fudeProtein)
                        NutritionEditRow(label: "Carbohydrates", value: scaledCarbs.gramString, color: .fudeCarbs)
                        NutritionEditRow(label: "Fat", value: scaledFat.gramString, color: .fudeFat)
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)

                    SectionHeader(title: "Notes (Optional)")
                    VStack(spacing: 10) {
                        TextField(text: $notes, prompt: Text("E.g. home-cooked, with olive oil").foregroundStyle(.secondary)) {
                            Text("E.g. home-cooked, with olive oil")
                        }
                        .foregroundStyle(.primary)
                        .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.fudeBackground)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TopBarTitle(text: "Edit Entry")
                }
                ToolbarItem(placement: .cancellationAction) {
                    TopBarTextButton(title: "Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    TopBarTextButton(title: "Save", systemImage: "checkmark") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(quantityInGrams <= 0)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
            .onAppear {
                let servings = entry.quantityGrams / max(servingSizeGrams, 1)
                quantityText = String(format: "%g", servings)
                selectedUnit = .servings
                selectedMeal = entry.mealName
                notes = entry.notes ?? ""
            }
        }
    }

    // MARK: - Actions

    private func saveChanges() {
        guard quantityInGrams > 0 else { return }

        entry.quantityGrams = quantityInGrams
        entry.mealName = selectedMeal
        entry.notes = notes.isEmpty ? nil : notes

        // Recalculate snapshot macros from current food item data
        if let item = entry.foodItem {
            entry.snapshotCalories = item.caloriesPer100g.scaled(by: quantityInGrams)
            entry.snapshotProtein = item.proteinPer100g.scaled(by: quantityInGrams)
            entry.snapshotCarbohydrates = item.carbohydratesPer100g.scaled(by: quantityInGrams)
            entry.snapshotFat = item.fatPer100g.scaled(by: quantityInGrams)
        }

        // Update the parent log's cached totals
        entry.dailyLog?.recalculateTotals()

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Subview

private struct NutritionEditRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(label)
            }
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
