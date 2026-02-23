import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \BodyWeightEntry.date, order: .reverse) private var weightEntries: [BodyWeightEntry]

    @State private var selectedProfile: UserProfile? = nil

    private var profile: UserProfile? { profiles.first }
    private var latestWeight: BodyWeightEntry? { weightEntries.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let profile {
                        heroCard(profile: profile)

                        SectionHeader(title: "Daily Goals")
                        goalsCard(profile: profile)

                        SectionHeader(title: "Body Weight")
                        bodyWeightCard

                        SectionHeader(title: "Security")
                        securityCard(profile: profile)

                        SectionHeader(title: "Data")
                        dataCard
                    } else {
                        ContentUnavailableView(
                            "No Profile",
                            systemImage: "person.slash",
                            description: Text("Restart the app to set up your profile.")
                        )
                        .padding(.top, 60)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(Color.fudeBackground)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TopBarTitle(text: "Profile")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    TopBarTextButton(title: "Edit", systemImage: "pencil") {
                        selectedProfile = profile
                    }
                }
            }
        }
        .sheet(item: $selectedProfile) { p in
            GoalsEditorView(profile: p)
        }
    }

    // MARK: - Hero Card

    private func heroCard(profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.fudeAccentPrimary.opacity(0.15))
                    .frame(width: 72, height: 72)
                Text(initials(from: profile.displayName))
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.fudeAccentPrimary)
            }

            Text(profile.displayName)
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("\(Int(profile.dailyCalorieTarget)) kcal / day")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .background(
            LinearGradient(
                colors: [.fudePerformanceBackground, .fudePerformanceSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: 24,
                bottomTrailingRadius: 24
            )
        )
    }

    private func initials(from name: String) -> String {
        let words = name.split(separator: " ")
        if words.count >= 2,
           let first = words.first?.first,
           let last = words.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return words.first.flatMap { $0.first.map { String($0).uppercased() } } ?? "?"
    }

    // MARK: - Goals Card

    private func goalsCard(profile: UserProfile) -> some View {
        VStack(spacing: 10) {
            KeyValueRow(
                label: "Calories",
                value: "\(profile.dailyCalorieTarget.roundedCalories) kcal",
                isMonospaced: true
            )
            KeyValueRow(
                label: "Protein",
                value: profile.dailyProteinTarget.gramString,
                valueColor: .fudeProtein,
                isMonospaced: true
            )
            KeyValueRow(
                label: "Carbohydrates",
                value: profile.dailyCarbohydrateTarget.gramString,
                valueColor: .fudeCarbs,
                isMonospaced: true
            )
            KeyValueRow(
                label: "Fat",
                value: profile.dailyFatTarget.gramString,
                valueColor: .fudeFat,
                isMonospaced: true
            )
        }
        .padding(12)
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 12)
    }

    // MARK: - Body Weight Card

    private var bodyWeightCard: some View {
        VStack(spacing: 0) {
            if let entry = latestWeight {
                HStack {
                    Text(String(format: "%.1f kg", entry.weightKg))
                        .font(.title2.bold().monospacedDigit())
                    Spacer()
                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 10)

                Divider()

                NavigationLink(destination: BodyWeightLogView()) {
                    HStack {
                        Text("View History")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 10)
                }
                .buttonStyle(.plain)
            } else {
                HStack {
                    Text("No weight logged")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.bottom, 10)

                Divider()

                NavigationLink(destination: BodyWeightLogView()) {
                    HStack {
                        Text("Log Weight")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.fudeAccentPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 12)
    }

    // MARK: - Security Card

    private func securityCard(profile: UserProfile) -> some View {
        VStack(spacing: 10) {
            Toggle("Face ID / Touch ID Lock", isOn: Binding(
                get: { profile.biometricLockEnabled },
                set: { profile.biometricLockEnabled = $0 }
            ))
            .font(.subheadline.weight(.semibold))
            .toggleStyle(FudeToggleStyle())
        }
        .padding(12)
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 12)
    }

    // MARK: - Data Card

    private var dataCard: some View {
        VStack(spacing: 10) {
            Button("Reset App", role: .destructive) {
                authViewModel.signOut(modelContext: modelContext)
            }
            .buttonStyle(FudeGhostButtonStyle(tint: .red))
        }
        .padding(12)
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 12)
    }
}
