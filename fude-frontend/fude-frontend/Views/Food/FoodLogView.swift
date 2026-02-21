import SwiftUI
import SwiftData

struct FoodLogView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var todayLog: DailyLog?
    @State private var showSearch = false

    private var entriesByMeal: [(String, [FoodEntry])] {
        guard let log = todayLog else { return [] }
        let mealOrder = ["Breakfast", "Lunch", "Dinner", "Snack"]
        let grouped = Dictionary(grouping: log.entries) { $0.mealName }
        return mealOrder.compactMap { meal in
            guard let entries = grouped[meal], !entries.isEmpty else { return nil }
            return (meal, entries.sorted { $0.loggedAt < $1.loggedAt })
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let log = todayLog, !log.entries.isEmpty {
                    List {
                        ForEach(entriesByMeal, id: \.0) { meal, entries in
                            Section(meal) {
                                ForEach(entries) { entry in
                                    FoodEntryRow(entry: entry)
                                }
                                .onDelete { indexSet in
                                    deleteEntries(entries: entries, at: indexSet, log: log)
                                }
                            }
                        }
                    }
                } else {
                    EmptyStateView(
                        systemImage: "fork.knife",
                        title: "No meals logged today",
                        message: "Tap + to log your first meal.",
                        actionTitle: "Log Food",
                        action: { showSearch = true }
                    )
                }
            }
            .navigationTitle("Today's Log")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            FoodSearchView()
                .presentationDetents([.large])
                .onDisappear {
                    // Refresh log totals when search sheet closes
                    todayLog = fetchOrCreateTodayLog()
                }
        }
        .task {
            todayLog = fetchOrCreateTodayLog()
        }
    }

    private func fetchOrCreateTodayLog() -> DailyLog? {
        let today = Date().startOfDay
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date == today }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let log = DailyLog(date: today)
        modelContext.insert(log)
        return log
    }

    private func deleteEntries(entries: [FoodEntry], at indexSet: IndexSet, log: DailyLog) {
        indexSet.forEach { i in
            modelContext.delete(entries[i])
        }
        log.recalculateTotals()
    }
}

private struct FoodEntryRow: View {
    let entry: FoodEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.foodItem?.name ?? "Unknown food")
                    .font(.subheadline)
                Text("\(entry.quantityGrams.gramString)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(entry.snapshotCalories.calorieString)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}
