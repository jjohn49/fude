import SwiftUI

struct FoodSearchResultRow: View {
    let item: FoodItem

    var body: some View {
        HStack(spacing: 12) {
            // Source indicator dot
            Circle()
                .fill(item.source == FoodSource.openFoodFacts ? Color.green : Color.blue)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                    .lineLimit(2)

                if let brand = item.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(item.caloriesPer100g.roundedCalories) kcal")
                    .font(.subheadline.monospacedDigit())
                Text("per 100g")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
