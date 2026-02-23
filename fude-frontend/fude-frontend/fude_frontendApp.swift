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

/// V2: Added `waterMl` to DailyLog and the new `BodyWeightEntry` model.
enum FudeSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [UserProfile.self, FoodItem.self, FoodEntry.self, DailyLog.self, WorkoutSummary.self, BodyWeightEntry.self]
    }
}

enum FudeMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [FudeSchemaV1.self, FudeSchemaV2.self] }
    static var stages: [MigrationStage] {
        [MigrationStage.lightweight(fromVersion: FudeSchemaV1.self, toVersion: FudeSchemaV2.self)]
    }
}

// MARK: - App entry point

@main
struct fude_frontendApp: App {
    @State private var authViewModel = AuthViewModel()

    // Non-optional: makeContainer() always returns a valid container.
    // If migration fails (e.g. stale simulator store from a pre-migration run)
    // it wipes the SQLite files and retries with a fresh schema.
    let sharedModelContainer: ModelContainer = Self.makeContainer()

    private static func makeContainer() -> ModelContainer {
        let schema = Schema(versionedSchema: FudeSchemaV2.self)
        // Explicit URL so the wipe path below is reliable.
        let storeURL = URL.applicationSupportDirectory
            .appendingPathComponent("fude.store")
        let config = ModelConfiguration(url: storeURL)

        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: FudeMigrationPlan.self,
                configurations: [config]
            )
        } catch {
            // Migration failed (schema mismatch, corrupted WAL, etc.).
            // Wipe the three SQLite sidecar files and start fresh.
            // Acceptable for a local-first dev app — the user will re-enter their profile.
            print("[Fude] ⚠️ ModelContainer migration failed: \(error)")
            print("[Fude] Wiping store and retrying with clean schema.")
            let base = storeURL.path(percentEncoded: false)
            for path in [base, base + "-wal", base + "-shm"] {
                try? FileManager.default.removeItem(atPath: path)
            }
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("[Fude] ModelContainer unrecoverable after wipe: \(error)")
            }
        }
    }

    init() {
        let background = UIColor(Color.fudePerformanceBackground)
        let surface = UIColor(Color.fudePerformanceSurface)
        let accent = UIColor(Color.fudeAccentPrimary)

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = background
        tabBarAppearance.shadowColor = .clear
        tabBarAppearance.backgroundImage = UIImage()
        tabBarAppearance.shadowImage = UIImage()
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.55)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.55),
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = accent
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: accent,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = background
        UITabBar.appearance().tintColor = accent
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.55)
        UITabBar.appearance().isHidden = true

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = background
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]
        let barButtonAppearance = UIBarButtonItemAppearance()
        barButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: accent,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]
        navAppearance.buttonAppearance = barButtonAppearance
        navAppearance.doneButtonAppearance = barButtonAppearance
        navAppearance.backButtonAppearance = barButtonAppearance
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = accent
        UIBarButtonItem.appearance().tintColor = accent

        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()
        toolbarAppearance.backgroundColor = background
        toolbarAppearance.buttonAppearance = barButtonAppearance
        UIToolbar.appearance().standardAppearance = toolbarAppearance
        UIToolbar.appearance().scrollEdgeAppearance = toolbarAppearance

        UITableView.appearance().backgroundColor = background
        UITableViewCell.appearance().backgroundColor = surface
        UITableViewCell.appearance().selectionStyle = .none

        UISegmentedControl.appearance().selectedSegmentTintColor = accent.withAlphaComponent(0.25)
        UISegmentedControl.appearance().backgroundColor = background
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ], for: .highlighted)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: accent,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ], for: .selected)

        UITextField.appearance().textColor = UIColor.white
        UITextField.appearance().tintColor = accent
        UITextView.appearance().textColor = UIColor.white
        UITextView.appearance().tintColor = accent
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(.dark)
        }
    }
}
