import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            FoodLogView()
                .tabItem {
                    Label("Food", systemImage: "fork.knife")
                }

            WorkoutListView()
                .tabItem {
                    Label("Fitness", systemImage: "figure.run")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
    }
}
