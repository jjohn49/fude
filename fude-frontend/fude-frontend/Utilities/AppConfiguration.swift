import Foundation

enum AppConfiguration {
    enum Environment {
        case development
        case production
    }

    static let current: Environment = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()

    static var backendBaseURL: URL {
        switch current {
        case .development:
            // Pi running ghcr.io/jjohn49/fude-backend on the local network.
            // ATS exception for pi.local is declared in Info.plist.
            return URL(string: "http://pi.local:8080")!
        case .production:
            // Update to your Pi's public URL once behind a reverse proxy with TLS.
            // Example: https://api.yourdomain.com
            // Note: App Store submission requires HTTPS — do not ship with pi.local.
            return URL(string: "http://pi.local:8080")!
        }
    }
}
