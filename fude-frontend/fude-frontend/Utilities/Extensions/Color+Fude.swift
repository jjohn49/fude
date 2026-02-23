import SwiftUI

extension Color {
    // MARK: - Macro colours (do not change — used across rings, bars, pills, stat cards)
    static let fudeProtein      = Color(red: 0.29, green: 0.56, blue: 0.89)
    static let fudeCarbs        = Color(red: 0.95, green: 0.77, blue: 0.06)
    static let fudeFat          = Color(red: 0.93, green: 0.44, blue: 0.32)
    static let fudeFiber        = Color(red: 0.36, green: 0.78, blue: 0.54)
    static let fudeCalorieRing  = Color(red: 0.95, green: 0.32, blue: 0.68)

    // MARK: - Performance tokens (dark-first)
    static let fudePerformanceBackground = Color(red: 0.06, green: 0.06, blue: 0.07)
    static let fudePerformanceSurface    = Color(red: 0.09, green: 0.10, blue: 0.11)
    static let fudeAccentPrimary         = Color(red: 0.36, green: 0.84, blue: 0.98) // bright cyan
    static let fudeAccentSecondary       = Color(red: 0.78, green: 0.52, blue: 0.98) // vivid violet
    static let fudeAccentTertiary        = Color(red: 0.30, green: 0.92, blue: 0.64) // clean green
    static let fudePerformanceGlow       = fudeAccentPrimary.opacity(0.24)

    // MARK: - Backgrounds
    static let fudeBackground   = fudePerformanceBackground
    static let fudeSurface      = fudePerformanceSurface

    // MARK: - Meal accent colours (FoodLogView section headers + entry card left borders)
    static let fudeMealBreakfast = Color(red: 0.98, green: 0.72, blue: 0.17)  // amber
    static let fudeMealLunch     = Color(red: 0.29, green: 0.78, blue: 0.55)  // mint green
    static let fudeMealDinner    = Color(red: 0.47, green: 0.38, blue: 0.95)  // violet
    static let fudeMealSnack     = Color(red: 0.93, green: 0.44, blue: 0.32)  // coral
}
