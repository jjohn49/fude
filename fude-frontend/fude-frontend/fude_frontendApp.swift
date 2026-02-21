//
//  fude_frontendApp.swift
//  fude-frontend
//
//  Created by John Johnston on 2/21/26.
//

import SwiftUI
import SwiftData

@main
struct fude_frontendApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            FoodItem.self,
            FoodEntry.self,
            DailyLog.self,
            WorkoutSummary.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
