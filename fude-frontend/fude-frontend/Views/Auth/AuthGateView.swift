import SwiftUI
import SwiftData

// TODO: Phase 5 - Re-add .unauthenticated → SignInWithAppleView branch
// when moving to a paid Apple Developer account.

struct AuthGateView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        switch authViewModel.state {
        case .unknown:
            ProgressView("Loading…")
                .task {
                    await authViewModel.checkAuthState(modelContext: modelContext)
                }

        case .setup:
            SetupView()

        case .requiresBiometric:
            BiometricPromptView()

        case .authenticated:
            MainTabView()

        case .error(let message):
            ErrorView(message: message)
        }
    }
}

// MARK: - Setup View (first launch)

private struct SetupView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var displayName: String = ""
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.orange)

                Text("Welcome to Fude")
                    .font(.largeTitle.bold())

                Text("Track nutrition and fitness,\nprivately on your device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("What should we call you?")
                    .font(.headline)

                TextField("Your name", text: $displayName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.givenName)
                    .focused($nameFieldFocused)
                    .submitLabel(.go)
                    .onSubmit { startApp() }
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button(action: startApp) {
                    Text("Get Started")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(displayName.trimmingCharacters(in: .whitespaces).isEmpty ? Color.orange.opacity(0.5) : Color.orange)
                        .foregroundStyle(.white)
                        .font(.headline)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)

                Text("Your data stays on your device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .onAppear { nameFieldFocused = true }
    }

    private func startApp() {
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        authViewModel.completeSetup(displayName: displayName, modelContext: modelContext)
    }
}

// MARK: - Biometric Prompt View

private struct BiometricPromptView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "faceid")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundStyle(.blue)

            Text("Unlock Fude")
                .font(.title2.bold())

            Text("Use Face ID or your passcode to continue.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            if authViewModel.isLoading {
                ProgressView()
            } else {
                Button("Unlock") {
                    Task {
                        await authViewModel.authenticateWithBiometrics()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            Spacer()
        }
        .task {
            await authViewModel.authenticateWithBiometrics()
        }
    }
}

// MARK: - Error View

private struct ErrorView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundStyle(.orange)

            Text("Authentication Error")
                .font(.title3.bold())

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Try Again") {
                authViewModel.dismissError()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
