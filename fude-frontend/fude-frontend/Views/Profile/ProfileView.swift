import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var showGoalsEditor = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                if let profile {
                    Section("Account") {
                        LabeledContent("Name", value: profile.displayName)
                        // TODO: Phase 5 - Show Apple ID email here once Sign in with Apple is re-enabled
                    }

                    Section("Daily Goals") {
                        LabeledContent("Calories", value: "\(profile.dailyCalorieTarget.roundedCalories) kcal")
                        LabeledContent("Protein", value: profile.dailyProteinTarget.gramString)
                        LabeledContent("Carbohydrates", value: profile.dailyCarbohydrateTarget.gramString)
                        LabeledContent("Fat", value: profile.dailyFatTarget.gramString)

                        Button("Edit Goals") {
                            showGoalsEditor = true
                        }
                    }

                    Section("Security") {
                        Toggle("Face ID / Touch ID Lock", isOn: Binding(
                            get: { profile.biometricLockEnabled },
                            set: { profile.biometricLockEnabled = $0 }
                        ))
                    }

                    Section {
                        // TODO: Phase 5 - Rename back to "Sign Out" once Apple Sign In is re-enabled
                        Button("Reset App", role: .destructive) {
                            authViewModel.signOut(modelContext: modelContext)
                        }
                    }
                } else {
                    Text("No profile found.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showGoalsEditor) {
            if let profile {
                GoalsEditorView(profile: profile)
            }
        }
    }
}
