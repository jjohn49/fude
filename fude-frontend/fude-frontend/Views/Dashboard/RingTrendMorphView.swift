import SwiftUI

/// Morphs the dashboard rings into a 7-day line chart in the same visual space.
struct RingTrendMorphView: View {
    let dailyLogs: [DailyLog]

    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double

    let calorieTarget: Double
    let proteinTarget: Double
    let carbsTarget: Double
    let fatTarget: Double

    let ringsAppeared: Bool
    let showLineChart: Bool

    @State private var morphProgress: CGFloat = 0

    private let ringLineWidth: CGFloat = 18
    private let ringGap: CGFloat = 8
    private let chartMaxScale: Double = 1.25

    private var days: [TrendDay] {
        let calendar = Calendar.current
        let today = Date().startOfDay

        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let log = dailyLogs.first(where: { $0.date == date })
            return TrendDay(
                date: date,
                calories: log?.totalCalories ?? 0,
                protein: log?.totalProtein ?? 0,
                carbs: log?.totalCarbohydrates ?? 0,
                fat: log?.totalFat ?? 0
            )
        }
    }

    private var remainingText: (value: String, label: String, color: Color) {
        let remaining = calorieTarget - calories
        let color: Color = remaining < 0 ? .red : .white
        return ("\(abs(Int(remaining)))", remaining < 0 ? "over" : "remaining", color)
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)

            ZStack {
                chartGrid(size: size)
                    .opacity(clamp((morphProgress - 0.2) * 1.4))

                ForEach(Array(MorphMetric.allCases.enumerated()), id: \.element) { index, metric in
                    ringLayer(metric: metric, index: index, size: size)
                    lineLayer(metric: metric, index: index, size: size)
                }

                centerMetricLabel
                    .opacity(clamp(CGFloat(1) - morphProgress * 1.6))
                    .scaleEffect(CGFloat(1) - clamp(morphProgress) * 0.12)

                xAxisLabels
                    .frame(width: size, height: size, alignment: .bottom)
                    .opacity(clamp((morphProgress - 0.45) * 1.7))
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            morphProgress = showLineChart ? 1 : 0
        }
        .onChange(of: showLineChart) { _, isExpanded in
            withAnimation(.timingCurve(0.18, 0.84, 0.24, 1.0, duration: isExpanded ? 1.05 : 0.7)) {
                morphProgress = isExpanded ? 1 : 0
            }
        }
    }

    // MARK: - Layers

    private func ringLayer(metric: MorphMetric, index: Int, size: CGFloat) -> some View {
        let local = stagedProgress(index: index)
        let radius = (size / 2) - CGFloat(index) * (ringLineWidth + ringGap) - ringLineWidth / 2
        let diameter = max(radius * 2, 0)
        let progress = ringProgress(for: metric)
        let trackOpacity = Double(0.18 * (1 - local))
        let arcOpacity = Double(CGFloat(1) - local * 0.9)
        let shadowOpacity = Double(0.55 * (1 - local))

        return ZStack {
            Circle()
                .stroke(metric.color.opacity(trackOpacity), lineWidth: ringLineWidth)
                .frame(width: diameter, height: diameter)

            Circle()
                .trim(from: 0, to: progress * (1 - local))
                .stroke(
                    metric.color,
                    style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                )
                .frame(width: diameter, height: diameter)
                .rotationEffect(.degrees(-90 + (Double(morphProgress) * 420) + Double(index) * 18))
                .opacity(arcOpacity)
        }
        .shadow(color: metric.color.opacity(shadowOpacity), radius: 6, x: 0, y: 0)
    }

    private func lineLayer(metric: MorphMetric, index: Int, size: CGFloat) -> some View {
        let local = stagedProgress(index: index)
        let points = chartPoints(for: metric, size: size)
        let draw = clamp((local - 0.12) / 0.88)

        return ZStack {
            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .trim(from: 0, to: draw)
            .stroke(
                metric.color,
                style: StrokeStyle(lineWidth: 4.2, lineCap: .round, lineJoin: .round)
            )
            .opacity(clamp((local - 0.05) * 1.4))

            ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                Circle()
                    .fill(metric.color)
                    .frame(width: 4, height: 4)
                    .position(point)
                    .opacity(clamp((local - 0.55) * 2.2))
            }
        }
    }

    private var centerMetricLabel: some View {
        VStack(spacing: 2) {
            Text(remainingText.value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(remainingText.color)
                .monospacedDigit()
            Text(remainingText.label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(remainingText.color.opacity(0.8))
                .textCase(.uppercase)
                .tracking(0.8)
        }
    }

    private func chartGrid(size: CGFloat) -> some View {
        let insets = chartInsets(size: size)
        let plotHeight = size - insets.top - insets.bottom

        return ZStack {
            ForEach([0.0, 0.5, 1.0], id: \.self) { fraction in
                let y = insets.top + plotHeight * (1 - CGFloat(fraction / chartMaxScale))
                Path { path in
                    path.move(to: CGPoint(x: insets.leading, y: y))
                    path.addLine(to: CGPoint(x: size - insets.trailing, y: y))
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                .foregroundStyle(Color.white.opacity(0.15))
            }
        }
    }

    private var xAxisLabels: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                Text(day.xAxisLabel)
                    .font(.caption2)
                    .foregroundStyle(day.date.isToday ? .white : .secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 6)
    }

    // MARK: - Helpers

    private func ringProgress(for metric: MorphMetric) -> CGFloat {
        let ratio: Double
        switch metric {
        case .calories:
            ratio = calorieTarget > 0 ? min(calories / calorieTarget, 1.0) : 0
        case .protein:
            ratio = proteinTarget > 0 ? min(protein / proteinTarget, 1.0) : 0
        case .carbs:
            ratio = carbsTarget > 0 ? min(carbs / carbsTarget, 1.0) : 0
        case .fat:
            ratio = fatTarget > 0 ? min(fat / fatTarget, 1.0) : 0
        }
        return CGFloat(ringsAppeared ? ratio : 0)
    }

    private func chartPoints(for metric: MorphMetric, size: CGFloat) -> [CGPoint] {
        guard days.count > 1 else { return [] }

        let insets = chartInsets(size: size)
        let plotWidth = size - insets.leading - insets.trailing
        let plotHeight = size - insets.top - insets.bottom
        let stepX = plotWidth / CGFloat(days.count - 1)

        return days.enumerated().map { index, day in
            let value = metric.value(for: day)
            let target = targetValue(for: metric)
            let normalized = target > 0 ? min(value / target, chartMaxScale) / chartMaxScale : 0

            let x = insets.leading + CGFloat(index) * stepX
            let y = insets.top + plotHeight * (1 - CGFloat(normalized))
            return CGPoint(x: x, y: y)
        }
    }

    private func chartInsets(size: CGFloat) -> EdgeInsets {
        let side = max(10, size * 0.07)
        return EdgeInsets(top: 14, leading: side, bottom: 24, trailing: side)
    }

    private func targetValue(for metric: MorphMetric) -> Double {
        switch metric {
        case .calories: return calorieTarget
        case .protein: return proteinTarget
        case .carbs: return carbsTarget
        case .fat: return fatTarget
        }
    }

    private func stagedProgress(index: Int) -> CGFloat {
        let perRingDelay: CGFloat = 0.12
        let delayed = morphProgress - CGFloat(index) * perRingDelay
        return clamp(delayed / (CGFloat(1) - perRingDelay * 3))
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        min(max(value, 0), 1)
    }
}

private struct TrendDay: Identifiable {
    var id: Date { date }
    let date: Date
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double

    var xAxisLabel: String {
        if date.isToday { return "T" }
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

private enum MorphMetric: CaseIterable, Hashable {
    case calories
    case protein
    case carbs
    case fat

    var color: Color {
        switch self {
        case .calories: return .fudeCalorieRing
        case .protein: return .fudeProtein
        case .carbs: return .fudeCarbs
        case .fat: return .fudeFat
        }
    }

    func value(for day: TrendDay) -> Double {
        switch self {
        case .calories: return day.calories
        case .protein: return day.protein
        case .carbs: return day.carbs
        case .fat: return day.fat
        }
    }
}

#Preview {
    RingTrendMorphView(
        dailyLogs: [],
        calories: 1650,
        protein: 122,
        carbs: 178,
        fat: 58,
        calorieTarget: 2000,
        proteinTarget: 150,
        carbsTarget: 220,
        fatTarget: 70,
        ringsAppeared: true,
        showLineChart: false
    )
    .frame(width: 220, height: 220)
    .padding()
    .background(Color.fudeBackground)
    .preferredColorScheme(.dark)
}
