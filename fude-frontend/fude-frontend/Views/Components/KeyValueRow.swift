import SwiftUI

struct KeyValueRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    var isMonospaced: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            Spacer()
            if isMonospaced {
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(valueColor)
                    .monospacedDigit()
            } else {
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(valueColor)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        KeyValueRow(label: "Calories", value: "2,100 kcal", isMonospaced: true)
        KeyValueRow(label: "Protein", value: "150 g", valueColor: .fudeProtein, isMonospaced: true)
    }
    .padding()
    .background(Color.fudeBackground)
}
