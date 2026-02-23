import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .kerning(1.2)
                .foregroundStyle(.secondary)
            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.top, 6)
    }
}

#Preview {
    VStack(spacing: 12) {
        SectionHeader(title: "Daily Targets")
        SectionHeader(title: "Workout", subtitle: "Syncs when HealthKit is available")
    }
    .padding()
    .background(Color.fudeBackground)
}
