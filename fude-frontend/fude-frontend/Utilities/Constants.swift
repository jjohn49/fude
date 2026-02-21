import Foundation

enum KeychainKey {
    static let appleUserIdentifier = "fude.appleUserIdentifier"
    static let appleUserEmail = "fude.appleUserEmail"
    static let appleUserDisplayName = "fude.appleUserDisplayName"
}

enum FoodSource {
    static let openFoodFacts = "openfoodfacts"
    static let usda = "usda"
}

enum FoodItemCacheTTL {
    static let days: Double = 30
}
