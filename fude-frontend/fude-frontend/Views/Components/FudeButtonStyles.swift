import SwiftUI

struct FudePrimaryButtonStyle: ButtonStyle {
    var background: Color = .fudeAccentPrimary
    var foreground: Color = .black

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(foreground)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(background.opacity(configuration.isPressed ? 0.85 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct FudeGhostButtonStyle: ButtonStyle {
    var tint: Color = .fudeAccentPrimary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(tint.opacity(configuration.isPressed ? 0.18 : 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 12) {
        Button("Primary") {}
            .buttonStyle(FudePrimaryButtonStyle())
        Button("Ghost") {}
            .buttonStyle(FudeGhostButtonStyle())
    }
    .padding()
    .background(Color.fudeBackground)
}
