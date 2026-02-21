import SwiftData
import Foundation

@Model
final class UserProfile {
    var id: UUID
    var appleUserIdentifier: String
    var displayName: String
    var email: String?
    var createdAt: Date
    var updatedAt: Date

    // Daily nutrition goals
    var dailyCalorieTarget: Double
    var dailyProteinTarget: Double
    var dailyCarbohydrateTarget: Double
    var dailyFatTarget: Double

    // Preferences
    var preferredMealNames: [String]
    var usesMetricUnits: Bool
    var biometricLockEnabled: Bool

    init(appleUserIdentifier: String, displayName: String, email: String? = nil) {
        self.id = UUID()
        self.appleUserIdentifier = appleUserIdentifier
        self.displayName = displayName
        self.email = email
        self.createdAt = Date()
        self.updatedAt = Date()
        self.dailyCalorieTarget = 2000
        self.dailyProteinTarget = 150
        self.dailyCarbohydrateTarget = 200
        self.dailyFatTarget = 65
        self.preferredMealNames = ["Breakfast", "Lunch", "Dinner", "Snack"]
        self.usesMetricUnits = true
        self.biometricLockEnabled = true
    }
}
