import SwiftUI

struct MainTabView: View {
    private enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case food = "Food"
        case fitness = "Fitness"
        case profile = "Profile"

        var systemImage: String {
            switch self {
            case .dashboard: return "house.fill"
            case .food: return "fork.knife"
            case .fitness: return "figure.run"
            case .profile: return "person.circle.fill"
            }
        }

        var accentColor: Color {
            switch self {
            case .dashboard: return .fudeAccentPrimary
            case .food: return .fudeCarbs
            case .fitness: return .fudeAccentTertiary
            case .profile: return .fudeAccentSecondary
            }
        }
    }

    @State private var selection: Tab = .dashboard

    var body: some View {
        ZStack {
            Color.fudePerformanceBackground
                .ignoresSafeArea()

            switch selection {
            case .dashboard:
                DashboardView()
            case .food:
                FoodLogView()
            case .fitness:
                WorkoutListView()
            case .profile:
                ProfileView()
            }
        }
        .safeAreaInset(edge: .bottom) {
            customTabBar
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 18, weight: .semibold))
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(selection == tab ? tab.accentColor : Color.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .background(
            LinearGradient(
                colors: [
                    Color.fudePerformanceBackground.opacity(0.96),
                    Color.fudePerformanceSurface
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
