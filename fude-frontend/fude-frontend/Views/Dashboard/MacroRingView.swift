import SwiftUI

struct MacroRingView: View {
    let consumed: Double
    let target: Double

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(consumed / target, 1.0)
    }

    private var isOverTarget: Bool { consumed > target }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.fudeCalorieRing.opacity(0.2), lineWidth: 14)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    isOverTarget ? Color.red : Color.fudeCalorieRing,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)

            // Centre text
            VStack(spacing: 2) {
                Text("\(consumed.roundedCalories)")
                    .font(.title2.bold())
                Text("of \(target.roundedCalories)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("kcal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    MacroRingView(consumed: 1400, target: 2000)
        .frame(width: 160, height: 160)
        .padding()
}
