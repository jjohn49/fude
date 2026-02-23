import SwiftUI
import SwiftData

struct WorkoutListView: View {
    // HealthKit integration is deferred until a paid Apple Developer account is available.
    // WorkoutSummary model and WorkoutDetailView are in place and ready —
    // re-enable by adding the HealthKit entitlement, capability, and HealthKitService (Phase 7).

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Workout focus cards
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Training Guides")

                        WorkoutTypeCard(
                            type: .strength,
                            systemImage: "dumbbell.fill",
                            color: .fudeProtein
                        )
                        .padding(.horizontal, 12)

                        WorkoutTypeCard(
                            type: .running,
                            systemImage: "figure.run",
                            color: Color(red: 0.20, green: 0.78, blue: 0.35)
                        )
                        .padding(.horizontal, 12)
                    }

                    // HealthKit placeholder
                    HealthKitPlaceholderCard()
                        .padding(.horizontal, 12)
                }
                .padding(.top)
                .padding(.bottom, 32)
            }
            .background(Color.fudeBackground)
            .navigationTitle("")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TopBarTitle(text: "Workouts")
                }
            }
        }
    }
}

// MARK: - Workout Type Card

private enum WorkoutType {
    case strength, running
}

private struct WorkoutTypeCard: View {
    let type: WorkoutType
    let systemImage: String
    let color: Color

    @State private var expanded = false

    private var title: String {
        switch type {
        case .strength: return "Strength Training"
        case .running: return "Running"
        }
    }

    private var tagline: String {
        switch type {
        case .strength: return "Build muscle · Caloric surplus or maintenance"
        case .running: return "Endurance · Carb fuelling is key"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header — always visible
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    expanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: systemImage)
                            .font(.title3)
                            .foregroundStyle(color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                        Text(tagline)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }

            // Expanded nutrition guide
            if expanded {
                Divider()
                    .padding(.horizontal)

                switch type {
                case .strength:
                    StrengthNutritionGuide(color: color)
                case .running:
                    RunningNutritionGuide(color: color)
                }
            }
        }
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Strength Nutrition Guide

private struct StrengthNutritionGuide: View {
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NutrientRow(
                icon: "bolt.fill",
                iconColor: .fudeProtein,
                title: "Protein",
                detail: "1.6–2.2g / kg bodyweight per day",
                tip: "30–40g within 2 hours post-session for muscle protein synthesis"
            )
            Divider().padding(.leading, 52)

            NutrientRow(
                icon: "flame.fill",
                iconColor: .fudeCarbs,
                title: "Carbohydrates",
                detail: "4–7g / kg bodyweight per day",
                tip: "Prioritise carbs pre- and post-workout to fuel and recover"
            )
            Divider().padding(.leading, 52)

            NutrientRow(
                icon: "drop.fill",
                iconColor: .fudeFat,
                title: "Fat",
                detail: "No restriction — keep above 20% of total calories",
                tip: "Essential for hormone production, including testosterone"
            )
            Divider().padding(.leading, 52)

            NutrientRow(
                icon: "waveform.path",
                iconColor: color,
                title: "Electrolytes",
                detail: "Replace sodium lost in sweat",
                tip: "Especially important for heavy sweaters — add salt to post-workout meals"
            )
        }
        .padding(.bottom, 4)
    }
}

// MARK: - Running Nutrition Guide

private struct RunningNutritionGuide: View {
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NutrientRow(
                icon: "flame.fill",
                iconColor: .fudeCarbs,
                title: "Carbohydrates",
                detail: "5–10g / kg on heavy training days",
                tip: "< 60 min: normal intake  ·  60–90 min: 30g/hr during run  ·  90+ min: 60–90g/hr"
            )
            Divider().padding(.leading, 52)

            NutrientRow(
                icon: "bolt.fill",
                iconColor: .fudeProtein,
                title: "Protein",
                detail: "1.4–1.7g / kg bodyweight per day",
                tip: "Less critical during the run, important for recovery in the 2-hour window after"
            )
            Divider().padding(.leading, 52)

            NutrientRow(
                icon: "drop.fill",
                iconColor: Color(red: 0.42, green: 0.68, blue: 0.95),
                title: "Hydration",
                detail: "500ml before · 150–250ml every 15–20 min",
                tip: "Thirst is a late signal — drink on a schedule for runs over 30 min"
            )
            Divider().padding(.leading, 52)

            NutrientRow(
                icon: "waveform.path",
                iconColor: Color(red: 0.48, green: 0.37, blue: 0.65),
                title: "Electrolytes",
                detail: "Sodium 500–1000mg/hr in hot conditions",
                tip: "Also potassium (banana, sweet potato) and magnesium (nuts, leafy greens)"
            )
        }
        .padding(.bottom, 4)
    }
}

// MARK: - Nutrient Row

private struct NutrientRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let detail: String
    let tip: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(iconColor)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(tip)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 1)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - HealthKit Placeholder Card

private struct HealthKitPlaceholderCard: View {
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.fudeAccentPrimary.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "heart.text.clipboard.fill")
                    .font(.title3)
                    .foregroundStyle(Color.fudeAccentPrimary)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Workout Tracking")
                    .font(.subheadline.bold())
                Text("Connect HealthKit in Phase 5 to track real workouts, heart rate, and net calories.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Workout Row (Phase 5 — ready to use once HealthKit is enabled)

struct WorkoutRow: View {
    let workout: WorkoutSummary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.run")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(workout.workoutTypeName)
                    .font(.subheadline.bold())
                Text(workout.startDate.shortFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(workout.durationFormatted)
                    .font(.subheadline.monospacedDigit())
                if let cal = workout.activeCaloriesBurned {
                    Text("\(cal.roundedCalories) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
