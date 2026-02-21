import Foundation
import SwiftData

// TODO: Phase 5 - Re-introduce Apple Sign In states (unauthenticated / signInWithApple)
// when moving to a paid Apple Developer account. The biometric flow is unchanged.

enum AuthState: Equatable {
    case unknown        // startup check in progress
    case setup          // first launch — no profile yet
    case requiresBiometric
    case authenticated
    case error(String)

    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown): return true
        case (.setup, .setup): return true
        case (.requiresBiometric, .requiresBiometric): return true
        case (.authenticated, .authenticated): return true
        case (.error(let a), .error(let b)): return a == b
        default: return false
        }
    }
}

@Observable
final class AuthViewModel {
    var state: AuthState = .unknown
    var isLoading = false

    private let authService = AuthService()
    private let biometricService = BiometricService()

    // MARK: - App Launch Check

    func checkAuthState(modelContext: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        guard authService.hasStoredSession() else {
            // Check if a profile already exists in SwiftData but Keychain was cleared
            let profiles = (try? modelContext.fetch(FetchDescriptor<UserProfile>())) ?? []
            if let profile = profiles.first {
                // Restore session marker
                try? authService.persistLocalSession(
                    profileID: profile.id,
                    displayName: profile.displayName
                )
                state = profile.biometricLockEnabled ? .requiresBiometric : .authenticated
            } else {
                state = .setup
            }
            return
        }

        let profiles = (try? modelContext.fetch(FetchDescriptor<UserProfile>())) ?? []
        if let profile = profiles.first, profile.biometricLockEnabled {
            state = .requiresBiometric
        } else {
            state = .authenticated
        }
    }

    // MARK: - First Launch Setup

    func completeSetup(displayName: String, modelContext: ModelContext) {
        let profile = UserProfile(
            appleUserIdentifier: UUID().uuidString, // local placeholder; replaced by Apple ID in Phase 5
            displayName: displayName.isEmpty ? "Me" : displayName
        )
        modelContext.insert(profile)
        try? authService.persistLocalSession(profileID: profile.id, displayName: profile.displayName)
        state = .authenticated
    }

    // MARK: - Biometric Auth

    func authenticateWithBiometrics() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await biometricService.authenticate(reason: "Unlock Fude to access your health data")
            state = .authenticated
        } catch let error as BiometricError {
            state = .error(error.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Sign Out / Reset

    func signOut(modelContext: ModelContext) {
        authService.clearStoredSession()
        state = .setup
    }

    func dismissError() {
        state = authService.hasStoredSession() ? .requiresBiometric : .setup
    }
}
