import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var todayLog: DailyLog?
    @State private var showFoodSearch = false

    private var profile: UserProfile? { profiles.first }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Calorie Ring + Macros
                    VStack(spacing: 16) {
                        HStack {
                            Spacer()
                            MacroRingView(
                                consumed: todayLog?.totalCalories ?? 0,
                                target: profile?.dailyCalorieTarget ?? 2000
                            )
                            .frame(width: 160, height: 160)
                            Spacer()
                        }

                        MacroBarView(
                            protein: todayLog?.totalProtein ?? 0,
                            carbs: todayLog?.totalCarbohydrates ?? 0,
                            fat: todayLog?.totalFat ?? 0
                        )
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Quick Add
                    Button {
                        showFoodSearch = true
                    } label: {
                        Label("Log Food", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .font(.headline)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
            .background(Color.fudeBackground)
            .navigationTitle("\(greeting)!")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showFoodSearch) {
            FoodSearchView()
                .presentationDetents([.large])
                .onDisappear {
                    // Refresh ring + macro bar after logging
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
}
