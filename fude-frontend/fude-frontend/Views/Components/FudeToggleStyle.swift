import SwiftUI

struct FudeToggleStyle: ToggleStyle {
    var onColor: Color = .fudeAccentPrimary
    var offColor: Color = .white.opacity(0.12)

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(configuration.isOn ? onColor.opacity(0.25) : offColor)
                    .frame(width: 48, height: 28)
                Circle()
                    .fill(configuration.isOn ? onColor : Color.white.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .padding(4)
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: configuration.isOn)
            .onTapGesture { configuration.isOn.toggle() }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        Toggle("Biometric Lock", isOn: .constant(true))
            .toggleStyle(FudeToggleStyle())
        Toggle("Biometric Lock", isOn: .constant(false))
            .toggleStyle(FudeToggleStyle())
    }
    .padding()
    .background(Color.fudeBackground)
}
