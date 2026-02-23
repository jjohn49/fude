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
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Daily Targets")
                    VStack(spacing: 12) {
                        goalFieldRow(label: "Calories (kcal)", text: $calories, placeholder: "2000")
                        goalFieldRow(label: "Protein (g)", text: $protein, placeholder: "150")
                        goalFieldRow(label: "Carbohydrates (g)", text: $carbs, placeholder: "200")
                        goalFieldRow(label: "Fat (g)", text: $fat, placeholder: "65")
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
            .scrollContentBackground(.hidden)
            .background(Color.fudeBackground)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TopBarTitle(text: "Edit Goals")
                }
                ToolbarItem(placement: .cancellationAction) {
                    TopBarTextButton(title: "Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    TopBarTextButton(title: "Save", systemImage: "checkmark") {
                        save()
                        dismiss()
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                calories = "\(profile.dailyCalorieTarget.roundedCalories)"
                protein = "\(profile.dailyProteinTarget.roundedCalories)"
                carbs = "\(profile.dailyCarbohydrateTarget.roundedCalories)"
                fat = "\(profile.dailyFatTarget.roundedCalories)"
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        if let v = Double(calories) { profile.dailyCalorieTarget = v }
        if let v = Double(protein) { profile.dailyProteinTarget = v }
        if let v = Double(carbs) { profile.dailyCarbohydrateTarget = v }
        if let v = Double(fat) { profile.dailyFatTarget = v }
        profile.updatedAt = Date()
    }

    private func goalFieldRow(label: String, text: Binding<String>, placeholder: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline.weight(.semibold))
            Spacer()
            TextField(text: text, prompt: Text(placeholder).foregroundStyle(.secondary)) {
                Text(placeholder)
            }
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .foregroundStyle(.primary)
            .foregroundColor(.white)
        }
        .padding(.vertical, 6)
    }
}
