import SwiftUI
import SwiftData

struct FoodLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dailyLogs: [DailyLog]
    @Query private var profiles: [UserProfile]

    @State private var showSearch = false
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false
    @State private var editingEntry: FoodEntry? = nil
    @State private var entryPendingDeletion: FoodEntry? = nil

    private var isToday: Bool { selectedDate.isToday }
    private var profile: UserProfile? { profiles.first }

    private var selectedLog: DailyLog? {
        let target = selectedDate.startOfDay
        return dailyLogs.first(where: { $0.date == target })
    }

    private var entriesByMeal: [(String, [FoodEntry])] {
        guard let log = selectedLog else { return [] }
        let order = ["Breakfast", "Lunch", "Dinner", "Snack"]
        let grouped = Dictionary(grouping: log.entries) { $0.mealName }
        return order.compactMap { meal in
            guard let entries = grouped[meal], !entries.isEmpty else { return nil }
            return (meal, entries.sorted { $0.loggedAt < $1.loggedAt })
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let log = selectedLog, !log.entries.isEmpty {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(entriesByMeal, id: \.0) { meal, entries in
                                VStack(spacing: 8) {
                                    MealSectionHeader(
                                        meal: meal,
                                        calories: entries.reduce(0) { $0 + $1.snapshotCalories }
                                    )
                                    .padding(.horizontal, 12)

                                    VStack(spacing: 8) {
                                        ForEach(entries) { entry in
                                            HStack(spacing: 8) {
                                                Button {
                                                    editingEntry = entry
                                                } label: {
                                                    FoodEntryCard(entry: entry, meal: meal)
                                                }
                                                .buttonStyle(.plain)

                                                Button(role: .destructive) {
                                                    entryPendingDeletion = entry
                                                } label: {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 13, weight: .semibold))
                                                        .frame(width: 30, height: 30)
                                                        .foregroundStyle(Color.red.opacity(0.75))
                                                        .background(Color.fudeSurface)
                                                        .clipShape(RoundedRectangle(cornerRadius: 9))
                                                }
                                                .buttonStyle(.plain)
                                                .opacity(0.9)
                                                .accessibilityLabel("Delete entry")
                                            }
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    entryPendingDeletion = entry
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                }
                            }

                            DayTotalsRow(log: log, profile: profile)
                                .padding(.horizontal, 12)
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 32)
                    }
                    .background(Color.fudeBackground)
                } else {
                    emptyState
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    dateButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    TopBarIconButton(systemImage: "plus", accessibilityLabel: "Add food") {
                        showSearch = true
                    }
                }
            }
            .background(Color.fudeBackground)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showSearch) {
            FoodSearchView(targetDate: selectedDate)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showDatePicker) {
            datePicker
        }
        .sheet(item: $editingEntry) { entry in
            EditFoodEntryView(entry: entry)
                .presentationDetents([.large])
        }
        .confirmationDialog(
            "Delete this food entry?",
            isPresented: Binding(
                get: { entryPendingDeletion != nil },
                set: { if !$0 { entryPendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let entry = entryPendingDeletion {
                    deleteEntry(entry: entry)
                }
                entryPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) {
                entryPendingDeletion = nil
            }
        } message: {
            Text("This will remove \(entryPendingDeletion?.foodItem?.name ?? "this item") from your log.")
        }
        .task {
            ensureLogExists(for: Date())
        }
        .onChange(of: selectedDate) { _, newDate in
            if newDate.isToday { ensureLogExists(for: newDate) }
        }
    }

    // MARK: - Toolbar Date Button

    private var dateButton: some View {
        Button {
            showDatePicker = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "calendar")
                    .font(.caption.weight(.semibold))
                Text(isToday ? "Today" : selectedDate.compactFormatted)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .kerning(0.4)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundStyle(.primary)
        }
    }

    // MARK: - Date Picker Sheet

    private var datePicker: some View {
        NavigationStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TopBarTitle(text: "Select Date")
                }
                ToolbarItem(placement: .topBarLeading) {
                    TopBarTextButton(title: "Today") {
                        selectedDate = Date()
                        showDatePicker = false
                    }
                    .disabled(isToday)
                }
                ToolbarItem(placement: .confirmationAction) {
                    TopBarTextButton(title: "Done", systemImage: "checkmark") { showDatePicker = false }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
        .presentationDetents([.medium])
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "fork.knife")
                .font(.system(size: 52, weight: .thin))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text(isToday ? "Nothing logged yet" : "No meals logged")
                    .font(.title3.weight(.semibold))
                Text(isToday
                    ? "Tap + to log your first meal."
                    : "No food was logged on \(selectedDate.compactFormatted).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if isToday {
                Button {
                    showSearch = true
                } label: {
                    Label("Log Food", systemImage: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Color.fudeAccentPrimary)
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.fudeBackground)
    }

    // MARK: - Helpers

    private func ensureLogExists(for date: Date) {
        let target = date.startOfDay
        let descriptor = FetchDescriptor<DailyLog>(predicate: #Predicate { $0.date == target })
        guard (try? modelContext.fetch(descriptor).first) == nil else { return }
        let log = DailyLog(date: target)
        modelContext.insert(log)
        try? modelContext.save()
    }

    private func deleteEntry(entry: FoodEntry) {
        if let log = entry.dailyLog {
            log.entries.removeAll { $0.id == entry.id }
            log.recalculateTotals()
        }
        modelContext.delete(entry)
        try? modelContext.save()
    }
}

// MARK: - Meal Section Header

private struct MealSectionHeader: View {
    let meal: String
    let calories: Double

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(mealColor)
                .frame(width: 6, height: 6)
            Text(meal)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(mealColor)
            Spacer()
            Text("\(Int(calories)) kcal")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.top, 6)
    }

    private var mealColor: Color {
        switch meal {
        case "Breakfast": return .fudeMealBreakfast
        case "Lunch":     return .fudeMealLunch
        case "Dinner":    return .fudeMealDinner
        default:          return .fudeMealSnack
        }
    }
}

// MARK: - Food Entry Card

private struct FoodEntryCard: View {
    let entry: FoodEntry
    let meal: String

    @GestureState private var isPressed = false

    private var accentColor: Color {
        switch meal {
        case "Breakfast": return .fudeMealBreakfast
        case "Lunch":     return .fudeMealLunch
        case "Dinner":    return .fudeMealDinner
        default:          return .fudeMealSnack
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 3)
                .padding(.vertical, 6)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.foodItem?.name ?? "Unknown food")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        MacroPill(label: "P", value: entry.snapshotProtein,       color: .fudeProtein)
                        MacroPill(label: "C", value: entry.snapshotCarbohydrates, color: .fudeCarbs)
                        MacroPill(label: "F", value: entry.snapshotFat,           color: .fudeFat)
                        Text("·  \(entry.quantityGrams.gramString)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(entry.snapshotCalories))")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.primary)
                    Text("kcal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in state = true }
        )
    }
}

// MARK: - Macro Pill

private struct MacroPill: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        Text("\(label) \(String(format: "%.0f", value))g")
            .font(.caption2.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

// MARK: - Day Totals Row

private struct DayTotalsRow: View {
    let log: DailyLog
    let profile: UserProfile?

    private var calorieTarget: Double { profile?.dailyCalorieTarget ?? 2000 }
    private var remaining: Double { calorieTarget - log.totalCalories }
    private var isOver: Bool { remaining < 0 }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Day Total")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(log.totalCalories.calorieString)
                    .font(.subheadline.monospacedDigit().weight(.semibold))
            }

            MacroBarView(
                protein: log.totalProtein,
                carbs: log.totalCarbohydrates,
                fat: log.totalFat
            )

            HStack {
                Label(
                    isOver
                        ? "\(Int(abs(remaining))) kcal over goal"
                        : "\(Int(remaining)) kcal remaining",
                    systemImage: isOver
                        ? "exclamationmark.triangle.fill"
                        : "checkmark.circle.fill"
                )
                .font(.caption.weight(.medium))
                .foregroundStyle(isOver ? .red : .secondary)
                Spacer()
                Text("Goal: \(Int(calorieTarget)) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color.fudeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Previews

#Preview {
    FoodLogView()
        .modelContainer(previewContainer())
}

#Preview("With Sample Data") {
    FoodLogView()
        .modelContainer(previewContainerWithSampleData())
}
