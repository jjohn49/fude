import Foundation

extension Double {
    var roundedCalories: Int { Int(rounded()) }
    var gramString: String { String(format: "%.1fg", self) }
    var calorieString: String { "\(roundedCalories) kcal" }

    func scaled(by quantityGrams: Double, per referenceGrams: Double = 100) -> Double {
        self * quantityGrams / referenceGrams
    }
}
