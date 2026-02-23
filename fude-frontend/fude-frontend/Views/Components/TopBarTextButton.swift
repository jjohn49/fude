import SwiftUI

struct TopBarTextButton: View {
    let title: String
    var systemImage: String? = nil
    var tint: Color = .fudeAccentPrimary
    var role: ButtonRole? = nil
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.caption.weight(.semibold))
                }
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.14))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        TopBarTextButton(title: "Cancel") {}
        TopBarTextButton(title: "Save", systemImage: "checkmark") {}
    }
    .padding()
    .background(Color.fudeBackground)
}
