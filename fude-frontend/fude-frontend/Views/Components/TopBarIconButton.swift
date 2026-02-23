import SwiftUI

struct TopBarIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    var tint: Color = .fudeAccentPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.18))
                    .frame(width: 34, height: 34)
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    TopBarIconButton(systemImage: "plus", accessibilityLabel: "Log food") {}
        .padding()
        .background(Color.fudeBackground)
}
