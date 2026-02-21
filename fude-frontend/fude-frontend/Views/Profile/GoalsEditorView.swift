import SwiftUI

struct GoalsEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let profile: UserProfile

    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Targets") {
                    LabeledContent("Calories (kcal)") {
                        TextField("2000", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Protein (g)") {
                        TextField("150", text: $protein)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Carbohydrates (g)") {
                        TextField("200", text: $carbs)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Fat (g)") {
                        TextField("65", text: $fat)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                }
            }
            .onAppear {
                calories = "\(profile.dailyCalorieTarget.roundedCalories)"
                protein = "\(profile.dailyProteinTarget.roundedCalories)"
                carbs = "\(profile.dailyCarbohydrateTarget.roundedCalories)"
                fat = "\(profile.dailyFatTarget.roundedCalories)"
            }
        }
    }

    private func save() {
        if let v = Double(calories) { profile.dailyCalorieTarget = v }
        if let v = Double(protein) { profile.dailyProteinTarget = v }
        if let v = Double(carbs) { profile.dailyCarbohydrateTarget = v }
        if let v = Double(fat) { profile.dailyFatTarget = v }
        profile.updatedAt = Date()
    }
}
