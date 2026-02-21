import Foundation

// TODO: Phase 5 - Replace this local auth with Apple Sign In (AuthenticationServices)
// when the project is moved to a paid Apple Developer account.
// The KeychainKey constants and KeychainService calls below can remain; just swap
// the user identifier source from UUID().uuidString to ASAuthorizationAppleIDCredential.user.

enum AuthError: LocalizedError {
    case profileNotFound
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .profileNotFound: return "No local profile found."
        case .unknown(let error): return "Authentication error: \(error.localizedDescription)"
        }
    }
}

struct AuthService {

    // MARK: - Session check

    /// Returns true if a local profile session marker exists in Keychain.
    func hasStoredSession() -> Bool {
        KeychainService.exists(key: KeychainKey.appleUserIdentifier)
    }

    // MARK: - Local profile bootstrap

    /// Creates a local session marker for a newly created profile.
    func persistLocalSession(profileID: UUID, displayName: String) throws {
        try KeychainService.save(key: KeychainKey.appleUserIdentifier, value: profileID.uuidString)
        try KeychainService.save(key: KeychainKey.appleUserDisplayName, value: displayName)
    }

    func clearStoredSession() {
        try? KeychainService.delete(key: KeychainKey.appleUserIdentifier)
        try? KeychainService.delete(key: KeychainKey.appleUserEmail)
        try? KeychainService.delete(key: KeychainKey.appleUserDisplayName)
    }

    func storedProfileID() -> UUID? {
        guard let raw = try? KeychainService.load(key: KeychainKey.appleUserIdentifier) else { return nil }
        return UUID(uuidString: raw)
    }

    func storedDisplayName() -> String? {
        try? KeychainService.load(key: KeychainKey.appleUserDisplayName)
    }
}
