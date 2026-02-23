import SwiftData
import Foundation

@Model
final class BodyWeightEntry {
    var id: UUID
    var date: Date
    var weightKg: Double
    var note: String

    init(date: Date = Date(), weightKg: Double, note: String = "") {
        self.id = UUID()
        self.date = date
        self.weightKg = weightKg
        self.note = note
    }
}
