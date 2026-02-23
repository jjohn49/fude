import SwiftUI

struct TopBarTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(.title3, design: .rounded).weight(.semibold))
            .kerning(0.6)
            .foregroundStyle(.primary)
    }
}

#Preview {
    TopBarTitle(text: "Dashboard")
        .padding()
        .background(Color.fudeBackground)
}
