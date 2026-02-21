//
//  fude_frontendApp.swift
//  fude-frontend
//
//  Created by John Johnston on 2/21/26.
//

import SwiftUI
import SwiftData

// MARK: - Schema versioning
// Add new VersionedSchema types here when model changes are required.
// Each schema must be listed in FudeMigrationPlan.schemas in order.

enum FudeSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [UserProfile.self, FoodItem.self, FoodEntry.self, DailyLog.self, WorkoutSummary.self]
    }
}

enum FudeMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [FudeSchemaV1.self] }
    static var stages: [MigrationStage] { [] } // add lightweight/custom stages here for future versions
}

// MARK: - App entry point

@main
struct fude_frontendApp: App {
    @State private var authViewModel = AuthViewModel()
    @State private var containerError: String? = nil

    var sharedModelContainer: ModelContainer? = {
        let schema = Schema(versionedSchema: FudeSchemaV1.self)
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        return try? ModelContainer(
            for: schema,
            migrationPlan: FudeMigrationPlan.self,
            configurations: [config]
        )
    }()

    var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                ContentView()
                    .environment(authViewModel)
                    .modelContainer(container)
            } else {
                StorageErrorView()
            }
        }
    }
}

// MARK: - Storage error fallback

private struct StorageErrorView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "externaldrive.badge.exclamationmark")
                .font(.system(size: 56))
                .foregroundStyle(.orange)
            Text("Storage Unavailable")
                .font(.title2.bold())
            Text("Fude couldn't open its database. Try restarting the app. If the problem persists, reinstalling will reset local data.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }
}
