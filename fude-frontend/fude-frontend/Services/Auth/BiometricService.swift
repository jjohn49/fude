import Foundation
import LocalAuthentication

enum BiometricError: LocalizedError {
    case notAvailable
    case notEnrolled
    case authFailed(Error)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .notAvailable: return "Biometric authentication is not available on this device."
        case .notEnrolled: return "No biometrics or passcode are set up. Please configure a passcode in Settings."
        case .authFailed(let error): return "Authentication failed: \(error.localizedDescription)"
        case .cancelled: return "Authentication was cancelled."
        }
    }
}

struct BiometricService {
    func isAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    func authenticate(reason: String) async throws {
        let context = LAContext()
        var canEvaluateError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &canEvaluateError) else {
            throw BiometricError.notAvailable
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,  // falls back to passcode
                localizedReason: reason
            )
            if !success {
                throw BiometricError.cancelled
            }
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .appCancel, .systemCancel:
                throw BiometricError.cancelled
            default:
                throw BiometricError.authFailed(error)
            }
        }
    }
}
