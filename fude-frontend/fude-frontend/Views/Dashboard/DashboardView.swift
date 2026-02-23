import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var dailyLogs: [DailyLog]
    @Query private var workouts: [WorkoutSummary]

    @State private var showFoodSearch = false
    @State private var ringsAppeared = false
    @State private var showMacroDrilldown = false

    private var profile: UserProfile? { profiles.first }

    private var todayLog: DailyLog? {
        let today = Date().startOfDay
        return dailyLogs.first(where: { $0.date == today })
    }

    private var calorieTarget: Double  { profile?.dailyCalorieTarget      ?? 2000 }
    private var proteinTarget: Double  { profile?.dailyProteinTarget       ?? 150 }
    private var carbsTarget: Double    { profile?.dailyCarbohydrateTarget  ?? 200 }
    private var fatTarget: Double      { profile?.dailyFatTarget           ?? 65 }

    private var calories: Double { todayLog?.totalCalories     ?? 0 }
    private var protein: Double  { todayLog?.totalProtein       ?? 0 }
    private var carbs: Double    { todayLog?.totalCarbohydrates ?? 0 }
    private var fat: Double      { todayLog?.totalFat           ?? 0 }

    private func progress(_ value: Double, _ target: Double) -> Double {
        guard target > 0 else { return 0 }
        return ringsAppeared ? min(value / target, 1.0) : 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroCard
                    WeeklyInsightsView(workouts: workouts)
                    waterCard
                }
                .padding(.bottom, 120)
            }
            .background(Color.fudeBackground)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                staticTopBar
            }
        }
        .sheet(isPresented: $showFoodSearch) {
            FoodSearchView()
                .presentationDetents([.large])
        }
        .task {
            _ = fetchOrCreateTodayLog()
            try? await Task.sleep(for: .milliseconds(150))
            withAnimation { ringsAppeared = true }
        }
    }

    private var staticTopBar: some View {
        HStack {
            Spacer()
            TopBarIconButton(systemImage: "plus", accessibilityLabel: "Log food") {
                showFoodSearch = true
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.fudePerformanceBackground)
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Concentric rings with center metric
            Button {
                withAnimation(.easeInOut(duration: 0.55)) {
                    showMacroDrilldown.toggle()
                }
            } label: {
                RingTrendMorphView(
                    dailyLogs: dailyLogs,
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                    calorieTarget: calorieTarget,
                    proteinTarget: proteinTarget,
                    carbsTarget: carbsTarget,
                    fatTarget: fatTarget,
                    ringsAppeared: ringsAppeared,
                    showLineChart: showMacroDrilldown
                )
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(showMacroDrilldown ? "Hide weekly macro trends" : "Show weekly macro trends")

            HStack(spacing: 6) {
                Image(systemName: showMacroDrilldown ? "chevron.up.circle.fill" : "waveform.path.ecg")
                    .font(.caption)
                    .foregroundStyle(Color.fudeAccentPrimary.opacity(0.9))
                Text(showMacroDrilldown ? "Trend drilldown expanded" : "Tap rings to unravel 7-day trends")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.62))
                    .textCase(.uppercase)
                    .tracking(0.6)
                Spacer()
                if showMacroDrilldown {
                    Button("Back to Rings") {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            showMacroDrilldown = false
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.fudeAccentPrimary.opacity(0.92))
                }
            }

            // Ring legend
            VStack(spacing: 10) {
                RingLegendRow(
                    color: .fudeCalorieRing,
                    label: "Calories",
                    progress: progress(calories, calorieTarget),
                    valueText: caloriesLegendText
                )
                RingLegendRow(
                    color: .fudeProtein,
                    label: "Protein",
                    progress: progress(protein, proteinTarget),
                    valueText: "\(Int(protein))g / \(Int(proteinTarget))g"
                )
                RingLegendRow(
                    color: .fudeCarbs,
                    label: "Carbs",
                    progress: progress(carbs, carbsTarget),
                    valueText: "\(Int(carbs))g / \(Int(carbsTarget))g"
                )
                RingLegendRow(
                    color: .fudeFat,
                    label: "Fat",
                    progress: progress(fat, fatTarget),
                    valueText: "\(Int(fat))g / \(Int(fatTarget))g"
                )
            }

            if showMacroDrilldown {
                MacroTrendDrilldownView(
                    dailyLogs: dailyLogs
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color.fudePerformanceBackground,
                    Color.fudePerformanceSurface,
                ],
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

    private var caloriesLegendText: String {
        let remaining = calorieTarget - calories
        return remaining >= 0
            ? "\(Int(remaining)) kcal left"
            : "\(Int(abs(remaining))) kcal over"
    }

    // MARK: - Water Card

    private var waterCard: some View {
        let waterTarget = 2500.0
        let consumed = todayLog?.waterMl ?? 0
        let prog = min(consumed / waterTarget, 1.0)
        let waterBlue = Color(red: 0.30, green: 0.65, blue: 0.98)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Water", systemImage: "drop.fill")
                    .font(.headline)
                    .foregroundStyle(waterBlue)
                Spacer()
                Text("\(Int(consumed)) / \(Int(waterTarget)) ml")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(waterBlue.opacity(0.15))
                        .frame(height: 8)
                    Capsule()
                        .fill(waterBlue)
                        .frame(width: geo.size.width * prog, height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: prog)
                }
            }
            .frame(height: 8)

            HStack(spacing: 8) {
                ForEach([150, 250, 330, 500], id: \.self) { amount in
                    Button("+\(amount)ml") { addWater(ml: Double(amount)) }
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(waterBlue.opacity(0.12))
                        .foregroundStyle(waterBlue)
                        .clipShape(Capsule())
                }
                Spacer()
                if consumed > 0 {
                    Button("Reset") { resetWater() }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Data

    @discardableResult
    private func fetchOrCreateTodayLog() -> DailyLog {
        let today = Date().startOfDay
        let descriptor = FetchDescriptor<DailyLog>(predicate: #Predicate { $0.date == today })
        if let existing = try? modelContext.fetch(descriptor).first { return existing }
        let log = DailyLog(date: today)
        modelContext.insert(log)
        try? modelContext.save()
        return log
    }

    private func addWater(ml: Double) {
        guard let log = todayLog else { return }
        log.waterMl += ml
        try? modelContext.save()
    }

    private func resetWater() {
        guard let log = todayLog else { return }
        log.waterMl = 0
        try? modelContext.save()
    }
}

// MARK: - Ring Legend Row

private struct RingLegendRow: View {
    let color: Color
    let label: String
    let progress: Double
    let valueText: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 62, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 4)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: progress)
                }
            }
            .frame(height: 4)

            Text(valueText)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 100, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

// MARK: - Previews

#Preview {
    DashboardView()
        .environment(AuthViewModel())
        .modelContainer(previewContainer())
}

#Preview("With Sample Data") {
    DashboardView()
        .environment(AuthViewModel())
        .modelContainer(previewContainerWithSampleData())
}
