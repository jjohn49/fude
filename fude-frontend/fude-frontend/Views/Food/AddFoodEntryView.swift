import SwiftUI
import SwiftData

struct AddFoodEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let foodItem: FoodItem
    var preselectedMeal: String? = nil
    var onLogged: (() -> Void)? = nil

    @State private var quantityText: String = "100"
    @State private var selectedMeal: String = "Breakfast"
    @State private var notes: String = ""

    private let meals = ["Breakfast", "Lunch", "Dinner", "Snack"]

    private var quantity: Double { Double(quantityText) ?? 100 }

    private var scaledCalories: Double { foodItem.caloriesPer100g.scaled(by: quantity) }
    private var scaledProtein: Double { foodItem.proteinPer100g.scaled(by: quantity) }
    private var scaledCarbs: Double { foodItem.carbohydratesPer100g.scaled(by: quantity) }
    private var scaledFat: Double { foodItem.fatPer100g.scaled(by: quantity) }

    var body: some View {
        NavigationStack {
            Form {
                // Food summary header
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(foodItem.name)
                            .font(.headline)
                        if let brand = foodItem.brand {
                            Text(brand)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Quantity
                Section("Quantity") {
                    HStack {
                        TextField("Amount", text: $quantityText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity)
                        Text("grams")
                            .foregroundStyle(.secondary)
                    }

                    // Quick-select buttons
                    HStack(spacing: 8) {
                        ForEach([50.0, 100.0, 150.0, 200.0], id: \.self) { g in
                            Button("\(Int(g))g") {
                                quantityText = "\(Int(g))"
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .tint(quantity == g ? .orange : .secondary)
                        }
                    }
                }

                // Meal picker
                Section("Meal") {
                    Picker("Meal", selection: $selectedMeal) {
                        ForEach(meals, id: \.self) { meal in
                            Text(meal).tag(meal)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Nutrition preview — updates live as quantity changes
                Section("Nutrition (estimated)") {
                    NutritionRow(label: "Calories", value: scaledCalories.calorieString, color: .fudeCalorieRing)
                    NutritionRow(label: "Protein", value: scaledProtein.gramString, color: .fudeProtein)
                    NutritionRow(label: "Carbohydrates", value: scaledCarbs.gramString, color: .fudeCarbs)
                    NutritionRow(label: "Fat", value: scaledFat.gramString, color: .fudeFat)
                }

                // Notes (optional)
                Section("Notes (optional)") {
                    TextField("E.g. home-cooked, with olive oil", text: $notes)
                }
            }
            .navigationTitle("Log Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        logEntry()
                    }
                    .fontWeight(.semibold)
                    .disabled(quantity <= 0)
                }
            }
            .onAppear {
                selectedMeal = preselectedMeal ?? currentMealSuggestion()
            }
        }
    }

    // MARK: - Actions

    private func logEntry() {
        let entry = FoodEntry(
            foodItem: foodItem,
            quantityGrams: quantity,
            mealName: selectedMeal
        )
        entry.notes = notes.isEmpty ? nil : notes

        // Find or create today's DailyLog
        let today = Date().startOfDay
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date == today }
        )
        let log: DailyLog
        if let existing = try? modelContext.fetch(descriptor).first {
            log = existing
        } else {
            log = DailyLog(date: today)
            modelContext.insert(log)
        }

        entry.dailyLog = log
        log.entries.append(entry)
        log.recalculateTotals()

        dismiss()
        onLogged?()
    }

    /// Suggests the most appropriate meal based on time of day.
    private func currentMealSuggestion() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11: return "Breakfast"
        case 11..<15: return "Lunch"
        case 15..<18: return "Snack"
        default: return "Dinner"
        }
    }
}

// MARK: - Subviews

private struct NutritionRow: View {
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
